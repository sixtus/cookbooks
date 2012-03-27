include_recipe "nepal::base"

node.default[:pureftpd][:use_flags] = %w(mysql)
node.default[:pureftpd][:auth] = ["mysql:/etc/pureftpd-mysql.conf"]
node.default[:pureftpd][:options] = "-A -E -H -j -U 133:022 -Z"

mysql_password = get_password("mysql/nepal_ftp")

mysql_user "nepal_ftp" do
  password mysql_password
  force_password true
end

mysql_grant "nepal_ftp" do
  user "nepal_ftp"
  privileges %w(SELECT)
  database "nepal"
end

template "/etc/pureftpd-mysql.conf" do
  source "ftp/pureftpd-mysql.conf"
  owner "root"
  group "root"
  mode "0640"
  variables :database_password => mysql_password
  notifies :restart, "service[pure-ftpd]"
end

include_recipe "pure-ftpd"
