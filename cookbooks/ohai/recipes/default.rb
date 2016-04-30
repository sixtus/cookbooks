ohai 'reload' do
  action :nothing
end

remote_directory node[:ohai][:plugin_path] do
  source "plugins"
  mode "0755"
  recursive true
  purge false
  action :nothing
  notifies :reload, 'ohai[reload]'
end.run_action(:create)

%w(
  linux/ps
  linux/hostname
  darwin/hostname
).each do |f|
  file "/var/lib/ohai/plugins/#{f}.rb" do
    action :nothing
    notifies :reload, 'ohai[reload]'
  end.run_action(:delete)
end
