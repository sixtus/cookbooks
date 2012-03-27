include_recipe "nepal::base"

portage_package_use "mail-mta/postfix|mysql" do
  package "mail-mta/postfix"
  use %w(mysql)
end

node.set[:skip][:postfix_satelite] = true

include_recipe "postfix::local"

mysql_dom_password = get_password("mysql/nepal_mail_dom")
mysql_user_password = get_password("mysql/nepal_mail_user")
mysql_alias_password = get_password("mysql/nepal_mail_alias")

mysql_user "nepal_mail_dom" do
  password mysql_dom_password
  force_password true
end

mysql_grant "nepal_mail_dom" do
  user "nepal_mail_dom"
  database "nepal"
  privileges %w(SELECT)
end

mysql_user "nepal_mail_user" do
  password mysql_user_password
  force_password true
end

mysql_grant "nepal_mail_user" do
  user "nepal_mail_user"
  database "nepal"
  privileges %w(SELECT)
end

mysql_user "nepal_mail_alias" do
  password mysql_alias_password
  force_password true
end

mysql_grant "nepal_mail_alias" do
  user "nepal_mail_alias"
  database "nepal"
  privileges %w(SELECT)
end

%w(
  virtual-alias-maps
  virtual-email2email-maps
  virtual-gid-maps
  virtual-mailbox-domains
  virtual-mailbox-maps
  virtual-uid-maps
).each do |c|
  template "/etc/postfix/mysql-#{c}.cf" do
    source "mail/mysql-#{c}.cf"
    owner "root"
    group "postfix"
    mode "0640"
    notifies :reload, "service[postfix]"
    variables :dom_password => mysql_dom_password,
              :user_password => mysql_user_password,
              :alias_password => mysql_alias_password
  end
end

postconf "nepal virtual maps" do
  set :virtual_mailbox_domains => "mysql:/etc/postfix/mysql-virtual-mailbox-domains.cf",
      :virtual_uid_maps => "mysql:/etc/postfix/mysql-virtual-uid-maps.cf",
      :virtual_gid_maps => "mysql:/etc/postfix/mysql-virtual-gid-maps.cf",
      :virtual_mailbox_maps => "mysql:/etc/postfix/mysql-virtual-mailbox-maps.cf",
      :virtual_alias_maps => "mysql:/etc/postfix/mysql-virtual-alias-maps.cf,mysql:/etc/postfix/mysql-virtual-email2email-maps.cf",
      :virtual_transport => "lmtp:unix:private/dovecot-lmtp"
end

portage_package_use "net-mail/dovecot|mysql" do
  package "net-mail/dovecot"
  use %w(mysql suid)
end

node.default[:dovecot][:auth][:modules] = %w(nepal)
node.default[:dovecot][:sieve][:path] = "/srv/system/etc/sieve/%d/%n.sieve"

include_recipe "dovecot"

directory "/srv/system/etc/sieve" do
  owner "nepal"
  group "nepal"
  mode "0755"
end

template "/etc/dovecot/nepal-sql.conf.ext" do
  source "mail/nepal-sql.conf.ext"
  owner "root"
  group "root"
  mode "0600"
  notifies :restart, "service[dovecot]"
  variables :user_password => mysql_user_password
end

template "/etc/dovecot/conf.d/auth-nepal.conf.ext" do
  source "mail/auth-nepal.conf.ext"
  owner "root"
  group "root"
  mode "0644"
  notifies :restart, "service[dovecot]"
end
