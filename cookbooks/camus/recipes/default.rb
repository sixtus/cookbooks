homedir = "/var/app/camus"

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

template "#{homedir}/current/camus.properties" do
  source "camus.properties"
  owner "camus"
  group "camus"
  mode "0644"
end

systemd_unit "camus.service" do
  action :delete
end

systemd_timer "camus" do
  action :delete
end

primary = (node[:fqdn] == camus_nodes.first[:fqdn]) rescue false

unit_defaults = {
  directory: "#{homedir}/current",
  user: "camus",
  group: "camus",
}

node[:camus][:topics].each do |name, properties|
  args = (properties || {}).merge({
    "kafka.whitelist.topics" => name,
    "camus.job.name" => "camus-#{name}",
    "etl.execution.base.path" => "#{node[:camus][:base_path]}/#{name}",
    "etl.execution.history.path" => "#{node[:camus][:history_path]}/#{name}",
  }).map do |key, value|
    "-D#{key}=#{value}"
  end.join(' ')

  systemd_timer "camus-#{name}" do
    schedule %w(OnCalendar=*:20 AccuracySec=20m)
    action :delete unless primary
    unit(unit_defaults.merge({
      command: "/var/app/camus/current/camus #{args}",
    }))
  end
end

if nagios_client?
  nagios_plugin "check_camus" do
    source "check_camus.rb"
  end
end
