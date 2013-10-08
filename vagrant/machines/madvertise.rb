Vagrant.configure("2") do |config|
  config.vm.define :madvertise do |mad|
    mad.vm.box = "madvertise-base"
    mad.vm.box_url = "http://ci.madvertise.me/downloads/amd64/madvertise-current.box"
    mad.vm.hostname = "vagrant.madvertise.local"
    mad.vm.network :private_network, ip: '10.10.10.10/24'
    mad.vm.provision :shell do |shell|
      shell.inline = "eix-sync"
    end
    mad.vm.provision :chef_solo do |chef|
      chef.binary_env = "LANG=en_US.UTF-8"
      chef.cookbooks_path = ["cookbooks", "site-cookbooks"]
      chef.data_bags_path = "databags"
      chef.roles_path = "roles"
      chef.json = {
        # hardcode tags here, since we are not able to store them on the chef
        # server when running chef-solo
        tags: [
          'druid-realtime',
          'hadoop-datanode',
          'hadoop-jobtracker',
          'hadoop-namenode',
          'zookeeper',
        ],
      }
      chef.add_role("base")
      chef.add_recipe("redis")
      chef.add_recipe("zookeeper")
      chef.add_recipe("mysql::server")
      chef.add_recipe("kafka::broker")
      chef.add_recipe("mongodb::server")
      chef.add_recipe("druid::realtime")
      chef.add_recipe("hadoop::namenode")
      chef.add_recipe("hadoop::datanode")
      chef.add_recipe("hadoop::jobtracker")
      chef.add_recipe("hadoop::tasktracker")
    end
  end
end