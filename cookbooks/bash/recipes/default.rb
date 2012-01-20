package value_for_platform(
  "gentoo" => {"default" => "app-shells/bash"},
  "mac_os_x" => {"default" => "bash"}
)

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
  cookbook_file "#{node[:bash][:rcdir]}/#{f}" do
    source f
    mode "0644"
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
