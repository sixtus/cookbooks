include_recipe "jenkins"

include_recipe "metro"

sudo_rule "jenkins-ezbuild" do
  user "jenkins"
  runas "ALL"
  command "NOPASSWD: /usr/local/metro/ezbuild *"
end

package "dev-util/packer"

sudo_rule "jenkins-packer" do
  user "jenkins"
  runas "ALL"
  command "NOPASSWD: /usr/bin/packer build -force template.json"
end
