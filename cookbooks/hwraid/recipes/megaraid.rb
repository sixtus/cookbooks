package "sys-block/megacli"

sudo_rule "nagios-megacli" do
  user "nagios"
  runas "root"
  command "NOPASSWD: /opt/bin/MegaCli -PDList -aALL -NoLog"
  only_if { nagios_client? }
end

sudo_rule "nagios-megacli-ldinfo" do
  user "nagios"
  runas "root"
  command "NOPASSWD: /opt/bin/MegaCli -LdInfo -Lall -aALL -NoLog"
  only_if { nagios_client? }
end

sudo_rule "nagios-megacli-bbu-status" do
  user "nagios"
  runas "root"
  command "NOPASSWD: /opt/bin/MegaCli -AdpBbuCmd -GetBbuStatus -aALL -NoLog"
  only_if { nagios_client? }
end
