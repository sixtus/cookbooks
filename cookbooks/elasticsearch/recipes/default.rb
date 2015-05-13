include_recipe "java"

deploy_skeleton "elasticsearch"

package_tar = "https://download.elastic.co/elasticsearch/elasticsearch/elasticsearch-#{node[:elasticsearch][:version]}.tar.gz"

release_dir = "/var/app/elasticsearch/releases/elasticsearch-#{node[:elasticsearch][:version]}"

tar_extract package_tar do
  target_dir "/var/app/elasticsearch/releases"
  creates release_dir
  user "elasticsearch"
  group "elasticsearch"
end

link "/var/app/elasticsearch/current" do
  to release_dir
end

%w{
  /var/app/elasticsearch/shared/data
  /var/app/elasticsearch/shared/work
  /var/app/elasticsearch/shared/logs
  /var/app/elasticsearch/shared/plugins
}.each do |dir|
  directory dir do
    owner "elasticsearch"
    group "elasticsearch"
    mode "0755"
  end
end

%w{
  logging.yml
  elasticsearch.yml
}.each do |conf|
  template "/var/app/elasticsearch/current/config/#{conf}" do
    source conf
    owner "root"
    group "root"
    mode "0644"
  end
end

systemd_unit "elasticsearch.service" do
  template true
end

service "elasticsearch" do
  action [:enable, :start]
end

if nagios_client?
  nagios_plugin "check_elasticsearch_health"

  nrpe_command "check_elasticsearch_health" do
    command "/usr/lib/nagios/plugins/check_elasticsearch_health"
  end

  nagios_service "ELASTICSEARCH-HEALTH" do
    check_command "check_nrpe!check_elasticsearch_health"
  end
end
