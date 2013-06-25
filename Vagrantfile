# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  config.vm.define :base do |base|
    base.vm.box = "zentoo-base"
    base.vm.box_url = "http://www.zentoo.org/downloads/amd64/base-current.box"
    base.vm.hostname = "base.zenops.ws"
    config.vm.provision :chef_solo do |chef|
      chef.cookbooks_path = "cookbooks"
      chef.add_recipe "base"
      chef.binary_env = "LANG=en_US.UTF-8"
    end
  end

  config.vm.define :chef do |chef|
    chef.vm.box = "zentoo-chef-server"
    chef.vm.box_url = "http://www.zentoo.org/downloads/amd64/chef-server-current.box"
    chef.vm.hostname = "chef.zenops.ws"
    chef.vm.network :private_network, ip: "10.42.9.2"
    chef.vm.synced_folder ".", "/vagrant", disabled: true
    chef.vm.provision :shell, path: "scripts/vagrant/bootstrap-server.sh"
  end

end
