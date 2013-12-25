if ganymed?
  package "net-analyzer/ganymed" do
    action :upgrade
    notifies :restart, "service[ganymed]"
  end

  %w(
    /etc/ganymed
    /usr/lib/ganymed
    /usr/lib/ganymed/collectors
  ).each do |dir|
    directory dir do
      owner "root"
      group "root"
      mode "0755"
    end
  end

  template "/etc/ganymed/config.yml" do
    source "config.yml"
    owner "root"
    group "root"
    mode "0644"
    notifies :restart, "service[ganymed]"
  end

  systemd_unit "ganymed.service"

  service "ganymed" do
    action [:enable, :start]
  end
end
