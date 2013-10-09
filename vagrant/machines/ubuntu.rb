Vagrant.configure("2") do |config|
  config.vm.define "ubuntu" do |base|
    base.vm.box = "ubuntu-12.04-amd64-base"
    base.vm.box_url = "http://mirror.zenops.net/ubuntu/amd64/ubuntu-12.04-amd64-base.box"
    setup_vrde(base, 5200)
    setup_chef_solo(base) do |chef|
      chef.add_role("base")
    end
  end
end