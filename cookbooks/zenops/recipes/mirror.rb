directory "/var/cache/mirror" do
  owner "root"
  group "root"
  mode "0755"
end

include_recipe "zenops::distfiles"
include_recipe "zenops::mirror-zentoo"

include_recipe "nginx"

nginx_server "mirror" do
  template "mirror/nginx.conf"
end

# shorewall
shorewall_rule "zenops-mirror" do
  destport "http,https"
end

shorewall6_rule "zenops-mirror" do
  destport "http,https"
end
