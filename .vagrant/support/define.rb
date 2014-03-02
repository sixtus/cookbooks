def define(name, ip)
  Vagrant.configure("2") do |config|
    config.vm.define name do |base|
      _chef = nil
      user = (ENV["USER"] || ENV["USERNAME"]).downcase.tr(" ", "-")
      base.vm.hostname = "#{name}.#{user}.zenops.ws"
      base.vm.network "private_network", ip: ip
      if File.exist?("vagrant/provision/#{name}.sh")
        base.vm.provision :shell, path: "vagrant/provision/#{name}.sh"
      end
      base.vm.provision :chef_client do |chef|
        _chef = chef
      end
      base.chef_zero.chef_repo_path = "."
      base.chef_zero.cookbooks = Dir["./cookbooks/*"] + Dir["./site-cookbooks/*"]
      base.vm.provider "virtualbox" do |vb|
        vb.gui = false
      end
      yield base.vm, _chef if block_given?
      _chef.add_recipe('virtualbox::guest')
      _chef.json = _chef.json.merge({
        chef_domain: 'vagrantup.com',
      })
    end
  end
end
