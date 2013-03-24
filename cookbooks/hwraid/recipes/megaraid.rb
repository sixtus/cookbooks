package "sys-block/megacli"

if tagged?("nagios-client")
  sudo_rule "nagios-megacli" do
    user "nagios"
    runas "root"
    command "NOPASSWD: /opt/bin/MegaCli -PDList -aALL -NoLog"
  end
end
