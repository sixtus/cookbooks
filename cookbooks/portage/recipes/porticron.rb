package "app-portage/porticron" do
  action :remove
end

file "/etc/cron.daily/porticron" do
  action :delete
end

file "/etc/cron.weekly/porticron" do
  action :delete
end

file "/etc/cron.weekly/distfiles" do
  action :delete
end
