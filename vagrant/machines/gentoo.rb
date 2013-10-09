Vagrant.configure("2") do |config|
  config.vm.define "gentoo" do |base|
    base.vm.box = "gentoo-amd64-base"
    base.vm.box_url = "http://mirror.zenops.net/gentoo/amd64/gentoo-amd64-base.box"
    setup_vrde(base, 5100)
    setup_chef_solo(base) do |chef|
      chef.add_role("base")
    end
  end
end