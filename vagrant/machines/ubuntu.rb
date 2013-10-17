Vagrant.configure("2") do |config|

  # ubuntu base
  config.vm.define "ubuntu" do |base|
    base.vm.box = "ubuntu-12.04.3-amd64-base"
    base.vm.box_url = "http://mirror.zenops.net/ubuntu/amd64/ubuntu-12.04.3-amd64-base.box"
    setup(base, 5302, "ubuntu") do |chef|
      chef.add_role("base")
    end
  end
end
