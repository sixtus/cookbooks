define(:mac, 5402) do |vm, chef|
  vm.box = "mac_os_x-10.8.5+chef"
  vm.synced_folder ".", "/vagrant", disabled: true
end
