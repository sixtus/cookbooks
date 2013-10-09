# -*- mode: ruby -*-
# vi: set ft=ruby :

def setup_chef_solo(config)
  config.vm.provision :chef_solo do |chef|
    chef.binary_env = "LANG=en_US.UTF-8"
    chef.cookbooks_path = ["cookbooks", "site-cookbooks"]
    chef.data_bags_path = "databags"
    chef.roles_path = "roles"
    yield chef if block_given?
  end
end

def setup_vrde(config, port)
  config.vm.provider "virtualbox" do |vb|
    vb.customize ["modifyvm", :id, "--vrde", "on"]
    vb.customize ["modifyvm", :id, "--vrdeport", port.to_s]
    vb.customize ["modifyvm", :id, "--vrdeauthtype", "external"]
  end
end

Dir[File.dirname(__FILE__) + '/vagrant/machines/*.rb'].each { |file| require file }
