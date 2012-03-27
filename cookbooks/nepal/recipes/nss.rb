include_recipe "nepal::base"

mysql_user_password = get_password("mysql/nepal_nss_user")
mysql_root_password = get_password("mysql/nepal_nss_root")

mysql_user "nepal_nss_user" do
  password mysql_user_password
  force_password true
end

# TODO: table level privs
mysql_grant "nepal_nss_user" do
  user "nepal_nss_user"
  database "nepal"
  privileges %w(SELECT)
end

mysql_user "nepal_nss_root" do
  password mysql_root_password
  force_password true
end

mysql_grant "nepal_nss_root" do
  user "nepal_nss_root"
  database "nepal"
  privileges %w(SELECT)
end

package "sys-auth/libnss-mysql"

template "/etc/libnss-mysql.cfg" do
  source "nss/libnss-mysql.cfg"
  owner "root"
  group "root"
  mode "0644"
  variables :database_password => mysql_user_password
end

template "/etc/libnss-mysql-root.cfg" do
  source "nss/libnss-mysql-root.cfg"
  owner "root"
  group "root"
  mode "0644"
  variables :database_password => mysql_root_password
end

node.default[:nss][:modules][:passwd] = %w(files mysql)
node.default[:nss][:modules][:shadow] = %w(files mysql)
node.default[:nss][:modules][:group] = %w(files mysql)
