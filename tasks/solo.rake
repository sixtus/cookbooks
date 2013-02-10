require "highline/import"

def run_solo
  scfg = File.join(TOPDIR, "config", "solo.rb")
  puts ">>> Starting Chef Bootstrap ..."
  sh("chef-solo -c #{scfg} -j #{ENV['SOLO_CONFIG']}")
end

namespace :solo do

  task :create_solo_config do
    ENV['SOLO_USER'] = %x(whoami).chomp
    ENV['SOLO_FQDN'] = %x(hostname -f).chomp

    if ENV['SOLO_USER'] == "root"
      ENV['SOLO_CONFIG'] = File.join(TOPDIR, "config", "solo", "#{ENV['SOLO_FQDN']}.json")
      ENV['BATCH'] = "1"
      Rake::Task['ssl:do_cert'].invoke(ENV['SOLO_FQDN'])
    else
      ENV['SOLO_CONFIG'] = File.join(TOPDIR, "config", "solo", "#{ENV['SOLO_USER']}.json")
    end

    unless File.exist?(ENV['SOLO_CONFIG'])
      name = ask('Your name: ')
      email = ask('Your email address: ')
      github_user = ask('Your github username: ')

      b = binding()
      erb = Erubis::Eruby.new(File.read(File.join(TEMPLATES_DIR, 'solo.json')))

      File.open(ENV['SOLO_CONFIG'], "w") do |f|
        f.puts(erb.result(b))
      end
    end
  end

  task :mac_os_x => :create_solo_config do
    raise "running as root is not supported on mac os" if ENV['SOLO_USER'] == "root"

    run_solo

    current_shell = %x(dscl . -read /Users/#{ENV['SOLO_USER']} | grep '^UserShell:' | awk '{print $2}').chomp
    new_shell = "/usr/local/bin/bash"

    if File.exist?(new_shell) and current_shell != new_shell
      sh("sudo chsh -s #{new_shell} #{ENV['SOLO_USER']}")
    end
  end

  task :gentoo => :create_solo_config do
    run_solo
  end

end

desc "Bootstrap local node with chef-solo"
task :solo do
  ohai = Ohai::System.new
  ohai.require_plugin("os")
  ohai.require_plugin("platform")
  Rake::Task["solo:#{ohai[:platform]}"].invoke
end

task :han do
  puts "May the force be with you!"
end
