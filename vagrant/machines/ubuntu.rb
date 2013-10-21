define(:ubuntu, 5302) do |vm, chef|
  vm.box = "ubuntu-12.04.3-amd64-base"
  vm.box_url = "http://mirror.zenops.net/ubuntu/amd64/ubuntu-12.04.3-amd64-base.box"
end
