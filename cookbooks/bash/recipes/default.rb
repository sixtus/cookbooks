package value_for_platform(
  "gentoo" => {"default" => "app-shells/bash"},
  "mac_os_x" => {"default" => "bash"}
)

if platform?("mac_os_x")
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

if platform?("mac_os_x")
  %w(.bashrc .bash_profile .profile).each do |f|
    link "#{node[:homedir]}/#{f}" do
      to "#{node[:bash][:rcdir]}/bashrc"
    end
  end

  link "#{node[:homedir]}/.bash_logout" do
    to "#{node[:bash][:rcdir]}/bash_logout"
  end
end

%w(
  IP
  copy
  grab
  mktar
  urlscript
).each do |f|
  cookbook_file "/usr/local/bin/#{f}" do
    source "scripts/#{f}"
    mode "0755"
  end
end
