# service-vagrant-template

Ready to use template for building stuff with Vagrant and some additional-services:

* JDK 10
* [Supervisord](http://supervisord.org/)
* [Toxiproxy 2.x](https://github.com/Shopify/toxiproxy#cli-example)
* [Graphite](https://graphiteapp.org/) - [Link to Graphite on Vagrant](http://10.10.10.10:3080/)
* [Grafana](https://grafana.com/) - [Link to Grafana on Vagrant](http://10.10.10.10:3000/) user: admin, pass: admin
* [wrk2](https://github.com/giltene/wrk2)

## Provisioning

Provisioning is done using shell scripts, see `vagrant-scripts/provisioning.sh`.
