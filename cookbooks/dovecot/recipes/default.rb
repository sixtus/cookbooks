portage_package_use "net-mail/dovecot" do
  use node[:dovecot][:use_flags]
end

package "net-mail/dovecot"

group "dovecot" do
  gid 97
end

user "dovecot" do
  uid 97
  gid "dovecot"
  home "/dev/null"
end

ssl_ca "/etc/ssl/dovecot/ca" do
  notifies :restart, "service[dovecot]"
end

ssl_certificate "/etc/ssl/dovecot/server" do
  cn node[:fqdn]
  notifies :restart, "service[dovecot]"
end

template "/etc/dovecot/dovecot.conf" do
  source "dovecot.conf"
  owner "root"
  group "root"
  mode "0640"
  notifies :restart, "service[dovecot]"
end

%w(
  10-auth
  10-logging
  10-master
  10-ssl
  15-lda
  20-lmtp
  90-sieve
).each do |c|
  template "/etc/dovecot/conf.d/#{c}.conf" do
    source "#{c}.conf"
    owner "root"
    group "root"
    mode "0640"
    notifies :restart, "service[dovecot]"
  end
end

systemd_unit "dovecot.service"

service "dovecot" do
  action :enable
  supports [:reload]
end
