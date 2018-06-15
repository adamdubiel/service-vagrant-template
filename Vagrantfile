# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  config.vm.box = "ubuntu/bionic64"

  config.vm.box_check_update = false

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  # NOTE: This will enable public access to the opened port
  # config.vm.network "forwarded_port", guest: 80, host: 8080

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine and only allow access
  # via 127.0.0.1 to disable public access
  # config.vm.network "forwarded_port", guest: 80, host: 8080, host_ip: "127.0.0.1"

  config.vm.network "private_network", ip: "10.10.10.10"

  # graphite-web
  config.vm.network "forwarded_port", guest: 3080, host: 3080, host_ip: "127.0.0.1"
  # grafana
  config.vm.network "forwarded_port", guest: 3000, host: 3000, host_ip: "127.0.0.1"

  config.vm.provider :virtualbox do |vb|
    vb.name = "service-vagrant-template"
    vb.memory = 2048
    vb.cpus = 2
  end

  config.vm.provision "file", source: "vagrant-scripts", destination: "/tmp/vagrant-scripts"
  config.vm.provision "shell", path: "vagrant-scripts/provisioning.sh"
end
