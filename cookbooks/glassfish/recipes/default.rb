include_recipe "java"

account "glassfish" do
  comment "Glassfish Java EE 6 Application Server"
  home "/usr/local/glassfish"
  gid "glassfish"
end

GF_VERSION="3.1"

remote_file "/usr/local/glassfish/glassfish-#{GF_VERSION}.zip" do
  source "http://download.java.net/glassfish/#{GF_VERSION}/release/glassfish-#{GF_VERSION}.zip"
  owner "glassfish"
  group "glassfish"
  checksum "00948001"
end

bash "install-glassfish" do
  creates "/usr/local/glassfish/bin/asadmin"
  code <<-EOS
  tmpdir=$(mktemp -d)
  unzip /usr/local/glassfish/glassfish-#{GF_VERSION}.zip -d ${tmpdir}
  mv ${tmpdir}/glassfish3/* /usr/local/glassfish/
  rm -rf ${tmpdir}
  EOS
  user "glassfish"
  group "glassfish"
end

cookbook_file "/etc/init.d/glassfish" do
  source "glassfish.initd"
  owner "root"
  group "root"
  mode "0755"
end

service "glassfish" do
  action [:enable, :start]
end
