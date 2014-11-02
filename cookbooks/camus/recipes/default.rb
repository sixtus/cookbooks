include_recipe "java"

deploy_skeleton "camus"

deploy_application "camus" do
  repository node[:camus][:git][:repository]

  before_symlink do
    execute "mvn-clean-package" do
      command "/usr/bin/mvn clean package -DskipTests=true"
      cwd release_path
      user "camus"
      group "camus"
    end
  end
end

template "/var/app/camus/current/camus.properties" do
  source "camus.properties"
  owner "camus"
  group "camus"
  mode "0644"
end

systemd_unit "camus.service" do
  template true
end

primary = (node[:fqdn] == camus_nodes.first[:fqdn])

systemd_timer "camus" do
  schedule %w(OnCalendar=*:5)
  action :delete unless primary
end

if nagios_client?
  nagios_plugin "check_camus" do
    source "check_camus.rb"
  end
end
