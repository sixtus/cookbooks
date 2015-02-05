include_recipe "druid"

package "sys-process/parallel"

deploy_skeleton "dumbo"

deploy_ruby_application "dumbo" do
  repository node[:dumbo][:git][:repository]
  ruby_version "jruby-1.7.12"
end

file "/etc/druid/sources.spec" do
  content druid_sources.to_json
  owner "root"
  group "root"
  mode "0644"
end

file "/etc/druid/database.spec" do
  content mysql_master_connection(node[:druid][:cluster]).to_json
  owner "root"
  group "root"
  mode "0644"
end

template "/var/app/dumbo/current/config.yml" do
  source "dumbo.yml"
  owner "root"
  group "dumbo"
  mode "0644"
end

#systemd_unit "druid-dumbo.service" do
#  template true
#end

#if druid_dumbo_nodes.first
#  primary = (node[:fqdn] == druid_dumbo_nodes.first[:fqdn])
#else
#  primary = true
#end

#systemd_timer "druid-dumbo" do
#  schedule %w(OnCalendar=*:55)
#  action :delete unless primary
#end
