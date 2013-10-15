directory "/var/cache/mirror" do
  owner "root"
  group "root"
  mode "0755"
end

include_recipe "zenops::ci"
include_recipe "zenops::binhost"
include_recipe "zenops::distfiles"
include_recipe "zenops::mirror-zentoo"

rsync_module "mirror" do
  path "/var/cache/mirror"
  uid "nobody"
  gid "nobody"
  exclude "/.git* /eix.* /scripts"
end

include_recipe "nginx"

nginx_server "mirror" do
  template "mirror/nginx.conf"
end

# shorewall
shorewall_rule "zenops-mirror" do
  destport "http,https,rsync"
end

shorewall6_rule "zenops-mirror" do
  destport "http,https,rsync"
end
