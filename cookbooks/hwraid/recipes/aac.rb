package "sys-block/asm"

if tagged?("nagios-client")
  sudo_rule "nagios-arcconf" do
    user "nagios"
    runas "root"
    command "NOPASSWD: /usr/sbin/arcconf GETCONFIG *"
  end
end
