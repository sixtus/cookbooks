include_recipe "java"

basename = ::File.basename(node[:confluence][:download_url], '.tar.gz')

tar_extract node[:confluence][:download_url] do
  target_dir "/opt"
  creates "/opt/#{basename}"
  user "root"
  group "root"
end

link "/opt/confluence" do
  to "/opt/#{basename}"
end

cookbook_file "/opt/confluence/conf/logging.properties" do
  source "logging.properties"
  owner "root"
  group "root"
  notifies :restart, "service[confluence]"
end

template "/opt/confluence/conf/server.xml" do
  source "server.xml"
  owner "root"
  group "root"
  notifies :restart, "service[confluence]"
end

template "/opt/confluence/confluence/WEB-INF/classes/confluence-init.properties" do
  source "confluence-init.properties"
  owner "root"
  group "root"
  notifies :restart, "service[confluence]"
end

directory "/var/lib/confluence" do
  owner "root"
  group "root"
  mode "0750"
end

systemd_unit "confluence.service"

service "confluence" do
  action [:enable, :start]
end
