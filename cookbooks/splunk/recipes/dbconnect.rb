include_recipe "java"

git "/opt/splunk/etc/apps/dbx" do
  repository "https://github.com/zenops/splunk-DBConnect"
  reference "master"
  action :sync
end

%w(
  app
  java
  inputs
).each do |f|
  template "/opt/splunk/etc/apps/dbx/local/#{f}.conf" do
    source "apps/DBConnect/#{f}.conf"
    owner "root"
    group "root"
    mode "0644"
  end
end
