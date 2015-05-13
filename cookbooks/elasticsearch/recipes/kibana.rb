deploy_skeleton "kibana"

package_tar = "https://download.elastic.co/kibana/kibana/kibana-#{node[:elasticsearch][:kibana][:version]}.tar.gz"

release_dir = "/var/app/kibana/releases/kibana-#{node[:elasticsearch][:kibana][:version]}"

tar_extract package_tar do
  target_dir "/var/app/kibana/releases"
  creates release_dir
  user "kibana"
  group "kibana"
end

link "/var/app/kibana/current" do
  to release_dir
end

# unless there is elasticsearch already, install a search head
unless node.role?("elasticsearch")
  log "Ensuring this node is an elasticsearch head"
  node[:elasticsearch][:master] = false
  node[:elasticsearch][:data] = false
  include_recipe "elasticsearch::default"
else
  log "Local elasticsearch present"
end

%w{
  kibana.yml
}.each do |conf|
  template "/var/app/kibana/current/config/#{conf}" do
    source conf
    owner "root"
    group "root"
    mode "0644"
  end
end

journald_index_template = {
  template: "journald-*",
  aliases: {
    current_journald: {},
  },
  settings: {
    number_of_shards: 2 * (elasticsearch_nodes.length - 1),
    number_of_replicas: 1,
    index: {
      query: {
        default_field: "message",
      },
      store: {
        type: "mmapfs",
        compress: {
          stored: true,
          tv: true,
        }
      },
    }
  },
  mappings: {
    _default_: { 
      _all: { 
        enabled: false,
      },
      _source: {
        enabled: true,
        compress: false,
      },
      dynamic_templates: [
        # {
        #   string_template: { 
        #     match: "*",
        #     mapping: {
        #       type: "string",
        #       index: "not_analyzed",
        #     },
        #     match_mapping_type: "string",
        #   }
        # }
      ],
      properties: {
        ts: { type: "date", index: "not_analyzed" },
        host: { type: "string", index: "not_analyzed" },
        systemd_unit: { type: "string", index: "not_analyzed" },
        message: { type: "string", index: "analyzed" },
      },
    }
  }
}

http_request "ensuring elastic-journald index tempate" do
  url "http://#{node[:ipaddress]}:9200/_template/template_journald/"
  message journald_index_template.to_json
  action :put
end

systemd_unit "kibana.service" do
  template true
end

service "kibana" do
  action [:enable, :start]
end

execute "install elasticsearch curator" do
  command "/usr/bin/pip install elasticsearch-curator"
  not_if { ::File.exists?("/usr/bin/curator")}
end

template "/var/app/kibana/bin/elasticsearch-curation" do
  source "elasticsearch-curation"
  owner "root"
  group "root"
  mode "0555"
end

systemd_timer "elasticsearch-curation" do
  schedule %w(OnCalendar=daily)
  unit({
    command: "/var/app/kibana/bin/elasticsearch-curation",
    user: "kibana",
    group: "kibana",
  })
end

contacts = node.users.select do |u|
  u[:tags] and not (u[:tags] & ["hostmaster", "splunk"]).empty?
end.sort_by do |u|
  u[:id]
end

file "/var/app/kibana/users" do
  content contacts.map { |c| "#{c[:id]}:#{c[:password]}" }.join("\n")
  owner "root"
  group "nginx"
  mode "0640"
end

## nginx proxy
include_recipe "nginx"

ssl_certificate "/etc/ssl/nginx/kibana" do
  cn node[:elasticsearch][:kibana][:certificate]
end

nginx_server "kibana" do
  template "nginx.conf"
end

## open ports
shorewall_rule "kibana" do
  destport "http,https"
end

shorewall6_rule "kibana" do
  destport "http,https"
end
