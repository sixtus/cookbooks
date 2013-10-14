Vagrant.configure('2') do |config|

  config.vm.define 'zentoo' do |base|
    base.vm.box = 'zentoo-amd64-base'
    base.vm.box_url = 'http://mirror.zenops.net/zentoo/amd64/zentoo-amd64-base.box'
    setup_network(base, 5002)
    setup_chef_solo(base) do |chef|
      chef.add_role("base")
    end
  end

end
