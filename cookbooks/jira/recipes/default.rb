include_recipe "java"

basename = ::File.basename(node[:jira][:download_url], '.tar.gz')

tar_extract node[:jira][:download_url] do
  target_dir "/opt"
  creates "/opt/#{basename}"
  user "root"
  group "root"
end

link "/opt/jira" do
  to "/opt/#{basename}-standalone"
end

cookbook_file "/opt/jira/conf/logging.properties" do
  source "logging.properties"
  owner "root"
  group "root"
  notifies :restart, "service[jira]"
end

template "/opt/jira/conf/server.xml" do
  source "server.xml"
  owner "root"
  group "root"
  notifies :restart, "service[jira]"
end

template "/opt/jira/atlassian-jira/WEB-INF/classes/jira-application.properties" do
  source "jira-application.properties"
  owner "root"
  group "root"
  notifies :restart, "service[jira]"
end

directory "/var/lib/jira" do
  owner "root"
  group "root"
  mode "0750"
end

systemd_unit "jira.service"

service "jira" do
  action [:enable, :start]
end
