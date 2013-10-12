if gentoo?
  package "app-shells/bash"
elsif debian_based?
  package "bash"
  package "bash-completion"
elsif mac_os_x?
  package "bash"
  package "bash-completion"
end

directory node[:bash][:rcdir] do
  mode "0755"
end

%w(
  bash_logout
  bashcomp-modules
  bashcomp.sh
  bashrc
  color.sh
  detect.sh
  gentoo.sh
  prompt.sh
).each do |f|
  template "#{node[:bash][:rcdir]}/#{f}" do
    source f
    mode "0644"
  end
end

if root?
  template "/etc/profile" do
    source "profile"
    owner "root"
    group "root"
    mode "0644"
  end

  file "/root/.bashrc" do
    action :delete
  end

  file "/root/.profile" do
    action :delete
  end
end

if solo? and not root?
  %w(.bashrc .bash_profile .profile).each do |f|
    link "#{node[:homedir]}/#{f}" do
      to "#{node[:bash][:rcdir]}/bashrc"
    end
  end

  link "#{node[:homedir]}/.bash_logout" do
    to "#{node[:bash][:rcdir]}/bash_logout"
  end

  overridable_template "#{node[:homedir]}/.bashrc.local" do
    source "bashrc.local"
    namespace :user
    instance node[:current_user]
  end
end

# various color fixes for solarized
dir_colors = root? ? "/etc/DIR_COLORS" : "#{node[:homedir]}/.dir_colors"

cookbook_file dir_colors do
  source "dircolors.ansi-universal"
  mode "0644"
end

colordiffrc = root? ? "/etc/colordiffrc" : "#{node[:homedir]}/.colordiffrc"

cookbook_file colordiffrc do
  source "colordiffrc"
  mode "0644"
end

# scripts
%w(
  IP
  copy
  grab
  mktar
  urlscript
).each do |f|
  cookbook_file "#{node[:script_path]}/#{f}" do
    source "scripts/#{f}"
    mode "0755"
  end
end

execute "env-update" do
  action :nothing
  only_if { gentoo? }
end
