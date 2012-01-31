namespace :solo do

  desc "Bootstrap local Mac OS X node with chef-colo"
  task :mac, :username do |t, args|
    args.with_defaults(:username => %x(whoami).chomp)

    unless File.directory?("/usr/local")
      sh("sudo mkdir -p /usr/local")
      sh("sudo chmod g+rwx /usr/local")
      sh("sudo chgrp admin /usr/local")
    end

    scfg = File.join(TOPDIR, "bootstrap", "mac", "solo.rb")
    sjson = File.join(TOPDIR, "bootstrap", "mac", "#{args.username}.json")

    sh("chef-solo -c #{scfg} -j #{sjson}")
  end

end
