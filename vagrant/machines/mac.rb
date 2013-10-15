Vagrant.configure('2') do |config|

  # mac os x
  config.vm.define 'mac' do |base|
    base.vm.box = 'mac_os_x-10.8.5+chef'
    base.vm.hostname = "mac.zenops.ws"
    base.vm.synced_folder '.', '/vagrant', disabled: true
    setup_network(base, 5402)
  end
end
