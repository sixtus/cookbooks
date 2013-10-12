Vagrant.configure("2") do |config|
  config.vm.define "debian" do |base|
    base.vm.box = "debian-7.1.0-amd64-base"
    base.vm.box_url = "http://mirror.zenops.net/debian/amd64/debian-7.1.0-amd64-base.box"
    setup_vrde(base, 5200)
    setup_chef_solo(base) do |chef|
      chef.add_role("base")
    end
  end
end
