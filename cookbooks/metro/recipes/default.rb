package "app-cdr/cdrtools"
package "app-emulation/virtualbox"
package "sys-boot/syslinux"
package "sys-fs/squashfs-tools"

git "/usr/local/metro" do
  repository node[:metro][:repository]
  action :sync
end

# setup control directory
directory "#{node[:metro][:path][:mirror]}/amd64" do
  owner "root"
  group "root"
  mode "0755"
  recursive true
end

{
  ".control/remote/build" => node[:metro][:build],
  ".control/remote/subarch" => "amd64",
  ".control/strategy/seed" => "stage3",
  ".control/strategy/build" => "remote",
}.each do |path, content|
  directory "#{node[:metro][:path][:mirror]}/amd64/#{File.dirname(path)}" do
    owner "root"
    group "root"
    mode "0755"
    recursive true
  end

  file "#{node[:metro][:path][:mirror]}/amd64/#{path}" do
    content "#{content}\n"
    owner "root"
    group "root"
    mode "0644"
  end
end

# fetch initial seed from zentoo.org
directory "#{node[:metro][:path][:mirror]}/amd64/initial" do
  owner "root"
  group "root"
  mode "0755"
end

remote_file "#{node[:metro][:path][:mirror]}/amd64/initial/stage3-amd64-#{node[:metro][:build]}-initial.tar.bz2" do
  source "http://www.zentoo.org/downloads/amd64/stage3-current.tar.bz2"
  owner "root"
  group "root"
  not_if { File.exist?("#{node[:metro][:path][:mirror]}/amd64/.control/version") }
end

# setup version control
directory "#{node[:metro][:path][:mirror]}/amd64/.control/version" do
  owner "root"
  group "root"
  mode "0755"
end

file "#{node[:metro][:path][:mirror]}/amd64/.control/version/stage3" do
  content "initial\n"
  owner "root"
  group "root"
  mode "0644"
  not_if { File.exist?("#{node[:metro][:path][:mirror]}/amd64/.control/version/stage3") }
end

# setup weekly build
cron_weekly "metro" do
  command "exec /usr/local/metro/scripts/ezbuild.sh #{node[:metro][:build]} amd64"
end
