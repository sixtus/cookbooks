include_recipe "java"

package "dev-util/jenkins-bin"

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

package "app-text/sloccount"

include_recipe "jenkins::extras"

if tagged?("nagios-client")
  nrpe_command "check_jenkins" do
    command "/usr/lib/nagios/plugins/check_systemd jenkins.service /run/jenkins/jenkins.pid"
  end

  nagios_service "JENKINS" do
    check_command "check_nrpe!check_jenkins"
    env [:testing, :development]
  end
end
