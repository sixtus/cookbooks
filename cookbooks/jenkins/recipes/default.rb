include_recipe "java"

package "dev-util/jenkins-bin"
package "app-text/sloccount"

execute "jenkins-ssh-key" do
  command "ssh-keygen -f /var/lib/jenkins/.ssh/id_rsa -N '' -C jenkins@#{node[:fqdn]}"
  creates "/var/lib/jenkins/.ssh/id_rsa"
  user "jenkins"
  group "jenkins"
end

systemd_tmpfiles "jenkins"
systemd_unit "jenkins.service"

service "jenkins" do
  action [:enable, :start]
end

include_recipe "nginx"

ssl_certificate "/etc/ssl/nginx/jenkins" do
  cn node[:jenkins][:certificate]
end

nginx_server "jenkins" do
  template "nginx.conf"
end

shorewall_rule "jenkins" do
  destport "http,https"
end

shorewall6_rule "jenkins" do
  destport "http,https"
end
