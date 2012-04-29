def solo(user)
  scfg = File.join(TOPDIR, "config", "solo.rb")
  sjson = File.join(TOPDIR, "config", "solo", "#{user}.json")
  sh("chef-solo -c #{scfg} -j #{sjson}")
end

namespace :solo do

  desc "Bootstrap local Mac OS X node with chef-solo"
  task :mac do
    user = %x(whoami).chomp

    unless File.directory?("/usr/local")
      sh("sudo mkdir -p /usr/local")
      sh("sudo chmod g+rwx /usr/local")
      sh("sudo chgrp admin /usr/local")
    end

    solo(user)

    current_shell = %x(dscl . -read /Users/#{whoami} | grep '^UserShell:' | awk '{print $2}').chomp
    new_shell = "/usr/local/bin/bash"

    if File.exist?(new_shell) and current_shell != new_shell
      sh("sudo chsh -s #{new_shell} #{whoami}")
    end
  end

  desc "Bootstrap local Gentoo node with chef-solo"
  task :gentoo do
    user = %x(whoami).chomp
    solo(user)
  end

end

desc "Bootstrap local node with chef-solo"
task :solo do
  ohai = Ohai::System.new
  ohai.require_plugin("os")
  ohai.require_plugin("platform")
  Rake::Task["solo:#{ohai[:platform]}"].execute
end
