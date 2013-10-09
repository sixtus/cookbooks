Vagrant.configure("2") do |config|
  config.vm.define "zentoo-next" do |base|
    base.vm.box = "zentoo-amd64-base"
    base.vm.box_url = "http://mirror.zenops.net/zentoo-next/amd64/zentoo-next-amd64-base.box"
    setup_vrde(base, 5010)
    setup_chef_solo(base) do |chef|
      chef.add_role("base")
    end
  end
end