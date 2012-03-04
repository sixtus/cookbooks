# add custom plugin path
Ohai::Config[:plugin_path].unshift("/var/lib/chef/ohai")

# create directories during compile phase
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
  purge true
  action :nothing
end

rd.run_action(:create)

# replace automatic attributes with new data
o = Ohai::System.new
o.all_plugins
node.automatic_attrs.merge! o.data
