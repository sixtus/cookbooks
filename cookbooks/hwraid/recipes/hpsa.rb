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

package "sys-block/hpssacli"

sudo_rule "nagios-hpssacli-controller" do
  user "nagios"
  runas "root"
  command "NOPASSWD: /usr/sbin/hpssacli controller all show status"
  only_if { nagios_client? }
end

sudo_rule "nagios-hpssacli-logical" do
  user "nagios"
  runas "root"
  command "NOPASSWD: /usr/sbin/hpssacli controller * logicaldrive all show"
  only_if { nagios_client? }
end
