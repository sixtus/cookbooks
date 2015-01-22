include_recipe "java"

deploy_skeleton "elasticsearch"

deploy_application "elasticsearch" do
  repository node[:elasticsearch][:git][:repository]
  revision node[:elasticsearch][:git][:revision]

  before_symlink do
    execute "mvn-clean-install" do
      command "/usr/bin/mvn clean install -DskipTests=true"
      cwd release_path
      user "elasticsearch"
      group "elasticsearch"
    end
  end
end

template "/var/app/elasticsearch/shared/config/log4j.properties" do
  source "log4j.properties"
  owner "root"
  group "root"
  mode "0644"
end

template "/var/app/elasticsearch/bin/elasticsearch" do
  source "elasticsearch.sh"
  owner "root"
  group "root"
  mode "0755"
end

systemd_unit "elasticsearch.service"

service "elasticsearch" do
  action [:enable, :start]
end
