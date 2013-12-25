include_recipe "postfix"
include_recipe "postfix::adminforward"
include_recipe "postfix::relayhost"
include_recipe "postfix::tls"

smtpd_recipient_restrictions = %w(
  check_recipient_access\ hash:/etc/postfix/recipient
  permit_mynetworks
  reject_unauth_destination
  permit
)

postconf "relay-only restrictions" do
  set({
    smtpd_client_restrictions: "permit_mynetworks, reject",
    smtpd_recipient_restrictions: smtpd_recipient_restrictions.join(", "),
  })
end
