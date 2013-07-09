tag("java")

case node[:platform]
when "gentoo"
  case node[:java][:vm]
  when /^oracle-jdk-bin-/
    package "dev-java/oracle-jdk-bin" do
      action :upgrade
    end

  when /^icedtea-/
    portage_package_use "dev-java/icedtea" do
      use %w(javascript -webstart)
    end

    package "dev-java/icedtea" do
      action :upgrade
    end

  else
    raise "unsupported JVM: #{node[:java][:vm]}"
  end

  execute "ensure #{node[:java][:vm]} is the system vm" do
    command "eselect java-vm set system #{node[:java][:vm]}"
    not_if { %x(eselect --brief java-vm show system).strip == node[:java][:vm] }
  end

  package "dev-java/icedtea-bin" do
    action :remove
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
end
