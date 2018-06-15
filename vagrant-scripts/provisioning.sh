#!/bin/bash

# Installed packages
# * toxiproxy: TCP proxy to inject faults & delays in network traffic
# * wrk2: traffic generator with stable rps count
# * supervisor: manage running apps
# * OpenJDK 10

TOXI_VER=2.1.3

### Repositories

# update apt-get for all new deps
apt-get update

### python & httpie
apt-get install -y python-pip
pip -q install httpie

### wrk2
apt-get install -y build-essential libssl-dev

if [ ! -d /tmp/wrk2 ]; then
  (
    cd /tmp
    git clone https://github.com/giltene/wrk2.git
    cd wrk2
    make
    cp wrk /usr/local/bin
  )
fi

### graphite

apt-get install -y python-dev libcairo2-dev libffi-dev build-essential nginx virtualenv

# everything is installed in virtualenv at /opt/graphite
virtualenv /opt/graphite
source /opt/graphite/bin/activate

export PYTHONPATH="/opt/graphite/lib/:/opt/graphite/webapp/"
pip install --no-binary=:all: https://github.com/graphite-project/whisper/tarball/1.1.3
pip install --no-binary=:all: https://github.com/graphite-project/carbon/tarball/1.1.3
pip install --no-binary=:all: https://github.com/graphite-project/graphite-web/tarball/1.1.3
pip install gunicorn

PYTHONPATH=/opt/graphite/webapp /opt/graphite/bin/django-admin.py migrate --settings=graphite.settings --run-syncdb

# nginx
cat /tmp/vagrant-scripts/graphite-nginx.conf > /etc/nginx/sites-available/graphite
rm -f /etc/nginx/sites-enabled/default
ln -s /etc/nginx/sites-available/graphite /etc/nginx/sites-enabled

touch /var/log/nginx/graphite.access.log
touch /var/log/nginx/graphite.error.log
chmod 640 /var/log/nginx/graphite.*
chown www-data:www-data /var/log/nginx/graphite.*

# carbon cache
cp /opt/graphite/conf/carbon.conf.example /opt/graphite/conf/carbon.conf
cat /tmp/vagrant-scripts/graphite-retention.conf > /opt/graphite/conf/storage-schemas.conf

### grafana
wget -q -O /tmp/grafana.deb https://s3-us-west-2.amazonaws.com/grafana-releases/release/grafana_5.0.4_amd64.deb
dpkg -i /tmp/grafana.deb

### toxiproxy
# install toxiproxi
wget -q -O /tmp/toxiproxy.deb "https://github.com/Shopify/toxiproxy/releases/download/v${TOXI_VER}/toxiproxy_${TOXI_VER}_amd64.deb"
dpkg -i /tmp/toxiproxy.deb

# create toxiproxy user only if needed
id -u toxiproxy &>/dev/null || sudo useradd -s /bin/false -U -M toxiproxy

# startup scripts
cat /tmp/vagrant-scripts/toxiproxy.default > /etc/default/toxiproxy
cat /tmp/vagrant-scripts/toxiproxy.service > /lib/systemd/system/toxiproxy.service
ln -s /lib/systemd/system/toxiproxy.service /etc/systemd/system/multi-user.target.wants/toxiproxy.service

### supervisor
apt-get install -y supervisor
cat /tmp/vagrant-scripts/supervisor-apps.conf > /etc/supervisor/conf.d/apps.conf
supervisorctl reload

### openjdk 10/11
apt-get install -y openjdk-11-jdk

# workaround to regenerate certs in proper format
/usr/bin/printf '\xfe\xed\xfe\xed\x00\x00\x00\x02\x00\x00\x00\x00\xe2\x68\x6e\x45\xfb\x43\xdf\xa4\xd9\x92\xdd\x41\xce\xb6\xb2\x1c\x63\x30\xd7\x92' > /etc/ssl/certs/java/cacerts
/var/lib/dpkg/info/ca-certificates-java.postinst configure

### copy scripts
cp /tmp/vagrant-scripts/toxiproxy_setup_proxies.sh /home/vagrant
chmod +x /home/vagrant/toxiproxy_setup_proxies.sh

/home/vagrant/toxiproxy_setup_proxies.sh


### Services start
systemctl daemon-reload
systemctl enable grafana-server
systemctl enable nginx
systemctl enable toxiproxy

service nginx restart
service grafana-server start
service toxiproxy start
