portage_package_use "mail-mta/postfix|dovecot" do
  package "mail-mta/postfix"
  use %w(dovecot-sasl)
end

include_recipe "postfix"

postconf "Dovecot SASL/LDA" do
  set({
    smtpd_sasl_type: "dovecot",
    smtpd_sasl_path: "private/auth",
    smtpd_sasl_auth_enable: "yes",
  })
end
