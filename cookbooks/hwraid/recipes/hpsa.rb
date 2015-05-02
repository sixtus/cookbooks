package "sys-block/hpacucli"

sudo_rule "nagios-hpacucli-controller" do
  user "nagios"
  runas "root"
  command "NOPASSWD: /usr/sbin/hpacucli controller all show status"
  only_if { nagios_client? }
end

sudo_rule "nagios-hpacucli-logical" do
  user "nagios"
  runas "root"
  command "NOPASSWD: /usr/sbin/hpacucli controller * logicaldrive all show"
  only_if { nagios_client? }
end
