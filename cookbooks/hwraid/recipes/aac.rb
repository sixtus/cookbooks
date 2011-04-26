portage_package_keywords "=sys-block/asm-7.00.18781"

package "sys-block/asm"

sudo_rule "nagios-arcconf" do
  user "nagios"
  runas "root"
  command "NOPASSWD: /usr/sbin/arcconf GETCONFIG *"
end
