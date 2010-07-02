link "/etc/make.profile" do
  to node[:portage][:profile]
end

directory node[:portage][:confdir] do
  owner "root"
  group "root"
  mode "0755"
  action :create
  not_if "test -d #{node[:portage][:confdir]}"
end

%w(keywords mask unmask use).each do |type|
  path = "#{node[:portage][:confdir]}/package.#{type}"

  bash "backup-package.#{type}" do
    code "mv #{path} #{path}.bak"
    only_if "test -f #{path}"
  end

  directory path do
    owner "root"
    group "root"
    mode "0755"
    action :create
    not_if "test -d #{path}"
  end

  bash "restore-package.#{type}" do
    code "mv #{path}.bak #{path}/local"
    only_if "test -f #{path}.bak"
  end
end

directory "#{node[:portage][:make_conf]}.d" do
  owner "root"
  group "root"
  mode "755"
  action :create
  not_if "test -d #{node[:portage][:make_conf]}.d"
end

template "#{node[:portage][:make_conf]}.d/local.conf" do
  owner "root"
  group "root"
  mode "644"
  source "make.conf.local.erb"
  backup 0
end

template node[:portage][:make_conf] do
  owner "root"
  group "root"
  mode "644"
  source "make.conf.erb"
  cookbook "portage"
  variables({:sources => []})
  backup 0
end

package "app-portage/eix" do
  not_if "test -d /var/db/pkg/app-portage/eix-*"
end

portage_pkg "sys-apps/portage" do
  keywords %w(~sys-apps/sandbox-2.2 =sys-apps/portage-2.2*)
  unmask %w(=sys-apps/portage-2.2*)
end

%w(autounmask elogv gentoolkit portage-utils).each do |pkg|
  package "app-portage/#{pkg}"
end

cookbook_file "/etc/logrotate.d/portage" do
  source "portage.logrotate"
  mode "0644"
  backup 0
end

directory node[:portage][:distdir] do
  owner "root"
  group "portage"
end

cookbook_file "/etc/dispatch-conf.conf" do
  source "dispatch-conf.conf"
  mode "0644"
  backup 0
end
