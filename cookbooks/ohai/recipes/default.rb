# load custom plugins
Ohai::Config[:plugin_path].unshift("/var/lib/chef/ohai")

d = directory "/var/lib/chef/ohai" do
  owner "root"
  group "root"
  mode "0755"
  recursive true
  action :nothing
end

d.run_action(:create)

rd = remote_directory "/var/lib/chef/ohai" do
  source "plugins"
  owner "root"
  group "root"
  mode "0755"
  action :nothing
end

rd.run_action(:create)

o = Ohai::System.new
o.all_plugins
node.automatic_attrs.merge! o.data
