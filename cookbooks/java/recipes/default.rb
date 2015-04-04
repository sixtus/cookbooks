if gentoo?
  package "dev-java/oracle-jdk-bin" do
    version "1.7*"
  end

  package "dev-java/maven-bin"

  if root?
    execute "eselect-java-vm" do
      command "eselect java-vm set system oracle-jdk-bin-1.7"
      not_if { %x(eselect --brief java-vm show system).strip == "oracle-jdk-bin-1.7" }
    end

    cookbook_file "/etc/jstatd.policy" do
      source "jstatd.policy"
      owner "root"
      group "root"
      mode "0644"
      notifies :restart, "service[jstatd]"
    end

    systemd_unit "jstatd.service"

    service "jstatd" do
      action [:enable, :start]
    end

    remote_file "/usr/lib/jvm/jolokia.jar" do
      source "http://labs.consol.de/maven/repository/org/jolokia/jolokia-jvm/1.2.2/jolokia-jvm-1.2.2-agent.jar"
    end
  end
end

if nagios_client?
  cookbook_file "/usr/lib/ruby/site_ruby/nagios/plugin/jolokia.rb" do
    source "jolokia.rb"
    owner "root"
    group "root"
    mode "0644"
  end

  nagios_plugin "jmxquery.jar"
  nagios_plugin "check_jmx"
  nagios_plugin "check_jstat"
  nagios_plugin "check_jvm"

  sudo_rule "nagios-hsperfdata-chmod" do
    user "nagios"
    runas "root"
    command "NOPASSWD: /bin/chmod 644 /tmp/hsperfdata_*"
    only_if { nagios_client? }
  end

  sudo_rule "nagios-hsperfdata-ln" do
    user "nagios"
    runas "root"
    command "NOPASSWD: /bin/ln -nfs /tmp/hsperfdata_* /tmp/hsperfdata_*"
    only_if { nagios_client? }
  end

  sudo_rule "nagios-jstat" do
    user "nagios"
    runas "root"
    command "NOPASSWD: /usr/bin/jstat *"
    only_if { nagios_client? }
  end
end
