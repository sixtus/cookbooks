define(:gentoo, 5102) do |vm, chef|
  vm.box = "gentoo-amd64-base"
  vm.box_url = "http://mirror.zenops.net/gentoo/amd64/gentoo-amd64-base.box"
end
