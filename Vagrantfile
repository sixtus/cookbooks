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

Vagrant.configure("2") do |config|

  ## Zentoo machines (50xx)

  config.vm.define "zentoo" do |base|
    base.vm.box = "zentoo-amd64-base"
    base.vm.box_url = "http://mirror.zenops.net/zentoo/amd64/zentoo-amd64-base.box"
    setup_vrde(base, 5000)
    setup_chef_solo(base) do |chef|
      chef.add_role("base")
    end
  end

  config.vm.define "zentoo-next" do |base|
    base.vm.box = "zentoo-amd64-base"
    base.vm.box_url = "http://mirror.zenops.net/zentoo-next/amd64/zentoo-next-amd64-base.box"
    setup_vrde(base, 5010)
    setup_chef_solo(base) do |chef|
      chef.add_role("base")
    end
  end

  ## Gentoo machines (51xx)

  config.vm.define "gentoo" do |base|
    base.vm.box = "gentoo-amd64-base"
    base.vm.box_url = "http://mirror.zenops.net/gentoo/amd64/gentoo-amd64-base.box"
    setup_vrde(base, 5100)
    setup_chef_solo(base) do |chef|
      chef.add_role("base")
    end
  end

  ## Debian machines (52xx)

  config.vm.define "debian" do |base|
    base.vm.box = "debian-7.1.0-amd64-base"
    base.vm.box_url = "http://mirror.zenops.net/debian/amd64/debian-7.1.0-amd64-base.box"
    setup_vrde(base, 5200)
    setup_chef_solo(base) do |chef|
      chef.add_role("base")
    end
  end

  ## Ubuntu machines (53xx)

  config.vm.define "ubuntu" do |base|
    base.vm.box = "ubuntu-12.04-amd64-base"
    base.vm.box_url = "http://mirror.zenops.net/ubuntu/amd64/ubuntu-12.04-amd64-base.box"
    setup_vrde(base, 5200)
    setup_chef_solo(base) do |chef|
      chef.add_role("base")
    end
  end

  ## Mac OS X machines (54xx)

  config.vm.define 'macosx' do |base|
    base.vm.box = "macosx-ML2"
    setup_vrde(base, 5401)
  end

end
