use_inline_resources

action :create do
  nr = new_resource

  directory "/etc/duply/#{nr.name}" do
    owner "root"
    group "root"
    mode "0700"
  end

  template "/etc/duply/#{nr.name}/conf" do
    source "duply.conf"
    cookbook "duply"
    owner "root"
    group "root"
    mode "0600"
    variables nr: nr
  end

  systemd_timer "duply-bkp-#{nr.name}" do
    schedule %w(OnCalendar=daily)
    unit command: "/usr/bin/duply #{nr.name} bkp"
  end

  systemd_timer "duply-purge-#{nr.name}" do
    schedule %w(OnCalendar=weekly)
    unit command: "/usr/bin/duply #{nr.name} purge-full --force"
  end
end

action :delete do
  nr = new_resource

  directory "/etc/duply/#{nr.name}" do
    action :delete
    recursive true
  end

  systemd_timer "duply-bkp-#{nr.name}" do
    action :delete
  end

  systemd_timer "duply-purge-#{nr.name}" do
    action :delete
  end
end
