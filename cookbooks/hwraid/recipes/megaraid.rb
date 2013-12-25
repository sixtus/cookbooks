package "sys-block/megacli"

sudo_rule "nagios-megacli" do
  user "nagios"
  runas "root"
  command "NOPASSWD: /opt/bin/MegaCli -PDList -aALL -NoLog"
  only_if { nagios_client? }
end
