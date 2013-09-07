def reboot_wait(fqdn)
  system("ssh -t #{fqdn} '/usr/bin/sudo -i systemctl reboot'")
  wait_with_ping(fqdn, false)
  wait_with_ping(fqdn, true)
  loop do
    system("sudo /usr/lib/nagios/plugins/check_ssh #{fqdn}")
    break if $?.exitstatus == 0
    sleep 5
  end
  system("ssh -t #{fqdn} '/usr/bin/sudo -i uname -a'")
end
