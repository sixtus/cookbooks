case node[:platform]
when "gentoo"
  package "app-shells/bash"

when "mac_os_x"
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
end
