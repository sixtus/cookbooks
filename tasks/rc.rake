# remote commands for maintenance

def rc(default_query)
  ENV['QUERY'] = default_query if not ENV.key?('QUERY')
  Chef::Search::Query.new.search(:node, ENV['QUERY']).first.compact.sort_by { |n| n[:fqdn] }.each do |node|
    next if node[:skip] and node[:skip][:rc]
    puts(">>> #{node.name}")
    yield node
  end
end

namespace :rc do

  desc "Update gentoo packages"
  task :updateworld do
    rc("platform:gentoo") do |node|
      env = if ENV.include?('DONT_ASK')
              "/usr/bin/env UPDATEWORLD_DONT_ASK=1"
            else
              ""
            end
      system("ssh -t #{node.name} '/usr/bin/sudo -i #{env} /usr/local/sbin/updateworld'")
    end
  end

  desc "Update portage tree"
  task :sync do
    rc("platform:gentoo") do |node|
      system("ssh -t #{node.name} '/usr/bin/sudo -i /usr/bin/eix-sync'")
    end
  end

  desc "Run chef-client"
  task :converge do
    rc("ipaddress:[* TO *]") do |node|
      system("ssh -t #{node.name} '/usr/bin/sudo -i /usr/bin/chef-client'")
    end
  end

  desc "Open interactive shell"
  task :shell do
    rc("ipaddress:[* TO *]") do |node|
      if ENV.key?('NOSUDO')
        system("ssh -t #{node.name}'")
      else
        system("ssh -t #{node.name} '/usr/bin/sudo -i'")
      end
    end
  end

  desc "Run custom script"
  task :script, :name do |t, args|
    script = File.join(TOPDIR, 'scripts', args.name)
    raise "script '#{args.name}' not found" if not File.exist?(script)
    rc("ipaddress:[* TO *]") do |node|
      if ENV.key?('NOSUDO')
        system("cat '#{script}' | ssh #{node.name} '/bin/bash -s'")
      else
        system("cat '#{script}' | ssh #{node.name} '/usr/bin/sudo -i /bin/bash -s'")
      end
    end
  end

  desc "Run custom command"
  task :cmd do
    raise "CMD must be supplied" if not ENV.key?('CMD')
    rc("ipaddress:[* TO *]") do |node|
      if ENV.key?('NOSUDO')
        system("ssh -t #{node.name} '#{ENV['CMD']}'")
      else
        system("ssh -t #{node.name} '/usr/bin/sudo -H #{ENV['CMD']}'")
      end
    end
  end
end
