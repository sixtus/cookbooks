package "sys-block/asm"

sudo_rule "nagios-arcconf" do
  user "nagios"
  runas "root"
  command "NOPASSWD: /usr/sbin/arcconf GETCONFIG *"
  only_if { nagios_client? }
end
