define(:debian, 5202) do |vm, chef|
  vm.box = "debian-7.1.0-amd64-base"
  vm.box_url = "http://mirror.zenops.net/debian/amd64/debian-7.1.0-amd64-base.box"
  chef.add_role('base')
end
