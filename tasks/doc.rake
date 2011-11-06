namespace :doc do

  desc "Upload and deploy documentation"
  task :deploy => [ :generate ]
  task :deploy do
    system("knife cookbook upload chef")
    Chef::Search::Query.new.search(:node, "role:chef") do |n|
      system("ssh -t #{n[:fqdn]} '/usr/bin/sudo -H /usr/bin/chef-client'")
    end
  end

  desc "Generate all documentation sources"
  task :generate do
    system("rm -rf #{TOPDIR}/cookbooks/chef/files/default/documentation/html/*")
    system("make -C #{TOPDIR}/documentation html")
  end

end

task :doc => "doc:deploy"
