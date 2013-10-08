Vagrant.configure("2") do |config|
  config.vm.define 'macosx' do |base|
    base.vm.box = "macosx-ML2"
    setup_vrde(base, 5401)
  end
end