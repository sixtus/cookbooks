deploy_skeleton "consul"

modules = {
  consul: {
    zip: "https://releases.hashicorp.com/consul/#{node[:consul][:version]}/consul_#{node[:consul][:version]}_linux_amd64.zip",
    location: "/var/app/consul/releases/#{node[:consul][:version]}",
    binary: "consul",
  },
  ui: {
    zip: "https://releases.hashicorp.com/consul/#{node[:consul][:version]}/consul_#{node[:consul][:version]}_web_ui.zip",
    location: "/var/app/consul/releases/#{node[:consul][:version]}/ui",
    binary: "index.html",
  },
  envconsul: {
    zip: "https://releases.hashicorp.com/envconsul/#{node[:consul][:envconsul][:version]}/envconsul_#{node[:consul][:envconsul][:version]}_linux_amd64.zip",
    location: "/var/app/consul/releases/#{node[:consul][:version]}/envconsul-#{node[:consul][:envconsul][:version]}",
    binary: "envconsul",
    link_binary: true,
  },
  template: {
    zip: "https://releases.hashicorp.com/consul-template/#{node[:consul][:template][:version]}/consul-template_#{node[:consul][:template][:version]}_linux_amd64.zip",
    location: "/var/app/consul/releases/#{node[:consul][:version]}/consul-template-#{node[:consul][:template][:version]}",
    binary: "consul-template",
    link_binary: true,
  },
}

extra_repos = {
  consulcli: {
    repository: node[:consul][:consulcli][:repository],
    revision: node[:consul][:consulcli][:revision],
    before_symlink: "make",
    binaries: %w{
      /var/app/consul/extras/consulcli/current/bin/consul-cli
    }
  }
}

data_dir = "/var/app/consul/shared/data"
config_dir = "/var/app/consul/shared/config"
service_dir = "/var/app/consul/shared/config/services"
config_file = File.join(config_dir, "config.json")

([data_dir, config_dir] + modules.map{|k,v| v[:location]}).each do |dir|
  directory dir do
    owner "consul"
    group "consul"
    mode "0755"
    recursive true
  end
end

# Make the service folder public, so e.g. HA daemons can update it
directory service_dir do
  owner "consul"
  group "consul"
  mode "0777"
  recursive true
end

modules.each do |m, options|
  basename = File.basename(options[:zip])
  target_dir = options[:location]
  target_binary = File.join(target_dir, options[:binary])
  local_archive = File.join(target_dir, basename)

  remote_file basename do
    source options[:zip]
    path local_archive
    backup false
    group "consul"
    owner "consul"
    mode "0644"
  end

  execute "extract #{basename}" do
    command "unzip #{local_archive}"
    cwd target_dir
    creates target_binary
    group "consul"
    user "consul"
  end

  if options[:link_binary]
    link "/var/app/consul/current/#{options[:binary]}" do
      to target_binary
    end
  end
end

template File.join(modules[:consul][:location], "envconsul_lock") do
  source "envconsul_lock"
  group "consul"
  owner "consul"
  mode "0555"

  variables({
    release_path: modules[:consul][:location]
  })
end

link "/var/app/consul/current" do
  to modules[:consul][:location]
end

if gentoo?
  template "/etc/env.d/97consul" do
    source "97consul"
    owner "root"
    group "root"
    mode 0644
    notifies :run, 'execute[env-update]'
  end
end

is_server = node.role?("consul-server")


def consul_cluster(n)
  n.production? ? n[:cluster][:name].gsub(".", "_") : "dev"
end

consul_config = {
  bind_addr: node[:consul][:bind_addr],
  client_addr: "0.0.0.0",
  data_dir: data_dir,
  ui_dir: File.join(modules[:ui][:location]),
  datacenter: consul_cluster(node),
  log_level: "WARN",
  encrypt: node[:consul][:encrypt],
  server: is_server,
}


all_servers = node.nodes.role("consul-server").map{|n| {fqdn: n[:fqdn], cluster: consul_cluster(n) }}
local_servers = all_servers.select{|n| n[:fqdn] != node[:fqdn] && n[:cluster] == consul_cluster(node) }.map{|n| n[:fqdn]}
wan_servers = all_servers.select{|n| n[:cluster] != consul_cluster(node) }.map{|n| n[:fqdn]}

if local_servers.length > 0
  consul_config[:retry_join] = local_servers
end

if is_server
  consul_config[:bootstrap_expect] = node[:consul][:bootstrap_expect]

  if wan_servers.length > 0
    consul_config[:retry_join_wan] = wan_servers
  end
end

file config_file do
  owner "root"
  group "root"
  mode 0644

  content JSON.pretty_generate(consul_config)
end

if systemd_running?
  systemd_unit "consul.service"

  service "consul" do
    action [:start, :enable]

    subscribes :restart, "systemd_unit[consul]", :delayed
    subscribes :restart, "link[/var/app/consul/current]", :delayed
    subscribes :restart, "file[#{config_file}]", :delayed
  end
end

if zentoo?
  gem_package "diplomat" do
    action :install
  end.run_action(:install)
else
  chef_gem "diplomat" do
    action :install
    compile_time true
  end
end

require "diplomat"

extra_repos.each do |repo, options|
  deploy_branch "/var/app/consul/extras/#{repo}" do
    repository options[:repository]
    revision options[:revision]
    user "consul"

    symlink_before_migrate({})

    before_symlink do
      execute "clean-gopath-for-#{repo}" do
        command "rm -rf /var/app/consul/.go/*"
      end

      execute "#{repo}-make" do
        command options[:before_symlink]
        cwd release_path
        user "consul"
        environment({
          "HOME" => "/var/app/consul",
          "GOPATH" => "/var/app/consul/.go",
          "PATH" => "/var/app/consul/.go/bin:#{ENV['PATH']}",
        })
      end
    end
  end

  options[:binaries].each do |binary|
    link "/var/app/consul/current/#{File.basename(binary)}" do
      to binary
    end
  end
end
