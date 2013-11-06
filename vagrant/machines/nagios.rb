define(:nagios, 5102) do |vm, chef|
  vm.box = "zentoo-amd64-base"
  vm.box_url = "http://mirror.zenops.net/zentoo/amd64/zentoo-amd64-base.box"
  chef.add_role("nagios")
end
