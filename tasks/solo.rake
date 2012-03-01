namespace :solo do

  desc "Bootstrap local Mac OS X node with chef-colo"
  task :mac, :username do |t, args|
    whoami = %x(whoami).chomp
    args.with_defaults(:username => whoami)

    unless File.directory?("/usr/local")
      sh("sudo mkdir -p /usr/local")
      sh("sudo chmod g+rwx /usr/local")
      sh("sudo chgrp admin /usr/local")
    end

    scfg = File.join(TOPDIR, "config", "solo.rb")
    sjson = File.join(TOPDIR, "config", "solo", "#{args.username}.json")

    sh("chef-solo -c #{scfg} -j #{sjson}")

    current_shell = %x(dscl . -read /Users/#{whoami} | grep '^UserShell:' | awk '{print $2}').chomp
    new_shell = "/usr/local/bin/bash"

    if File.exist?(new_shell) and current_shell != new_shell
      sh("sudo chsh -s #{new_shell} #{whoami}")
    end
  end

end
