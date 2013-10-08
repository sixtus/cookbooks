Vagrant.configure("2") do |config|
    config.vm.define :staging do |staging|

    staging.vm.box = "madvertise-base"
    staging.vm.box_url = "http://ci.madvertise.me/downloads/amd64/madvertise-current.box"
    staging.vm.hostname = "staging.madvertise.local"
    staging.vm.network :private_network, ip: '10.10.10.20/24'

    staging.vm.provision :shell do |shell|
      shell.inline = "eix-sync"
    end

    staging.vm.provision :chef_solo do |chef|
      chef.binary_env = "LANG=en_US.UTF-8"
      chef.cookbooks_path = ["cookbooks", "site-cookbooks"]
      chef.data_bags_path = "databags"
      chef.roles_path = "roles"
      chef.environment = "staging"
      chef.environments_path = "config/solo"
      chef.add_role("app")
    end

    staging.vm.provider :virtualbox do |vb|
      vb.gui = true
    end
  end
end