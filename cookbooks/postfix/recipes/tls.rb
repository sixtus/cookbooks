include_recipe "postfix"
include_recipe "openssl"

directory "/etc/ssl/postfix" do
  owner "root"
  group "root"
  mode "0755"
end

ssl_ca "/etc/ssl/postfix/ca" do
  notifies :restart, "service[postfix]"
end

ssl_certificate "/etc/ssl/postfix/server" do
  cn node[:fqdn]
  notifies :restart, "service[postfix]"
end

postconf "TLS encryption" do
  set({
    smtpd_tls_cert_file: "/etc/ssl/postfix/server.crt",
    smtpd_tls_key_file: "/etc/ssl/postfix/server.key",
    smtpd_tls_security_level: "may",
    smtpd_tls_auth_only: "yes",
    smtpd_tls_session_cache_database: "btree:/var/lib/postfix/smtpd_scache",
    smtpd_tls_session_cache_timeout: "3600s",
  })
end

if nagios_client?
  nrpe_command "check_postfix_tls" do
    command "/usr/lib/nagios/plugins/check_ssl_server -H localhost -n #{node[:fqdn]} -r /etc/ssl/certs/ca-certificates.crt -P smtp -p 25 -w 21 -c 7"
  end

  nagios_service "POSTFIX-TLS" do
    check_command "check_nrpe!check_postfix_tls"
    notification_interval 1440
    servicegroups "postfix"
    env [:testing, :development]
  end
end
