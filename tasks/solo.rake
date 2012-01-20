namespace :solo do

  desc "Bootstrap local Mac OS X node with chef-colo"
  task :mac do
    scfg = File.join(TOPDIR, "bootstrap", "mac", "solo.rb")
    sjson = File.join(TOPDIR, "bootstrap", "mac", "solo.json")

    sh("chef-solo -c #{scfg} -j #{sjson}")
  end

end
