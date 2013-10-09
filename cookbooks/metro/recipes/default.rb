include_recipe "virtualbox"

package "app-cdr/cdrtools"
package "dev-python/boto"
package "sys-boot/syslinux"
package "sys-fs/squashfs-tools"

git "/usr/local/metro" do
  repository node[:metro][:repository]
  action :checkout
end

# setup boto credentials
template "/root/.boto" do
  source "boto.ini"
  owner "root"
  group "root"
  mode "0400"
end

[node[:metro][:builds]].flatten.each do |build|
  [node[:metro][:archs]].flatten.each do |arch|

    builddir = "#{node[:metro][:path][:mirror]}/#{build}/#{arch}"

    directory builddir do
      owner "root"
      group "root"
      mode "0755"
      recursive true
    end

    {
      ".control/remote/build" => build,
      ".control/remote/subarch" => arch,
      ".control/strategy/seed" => "stage3",
      ".control/strategy/build" => "remote",
    }.each do |path, content|
      directory "#{builddir}/#{File.dirname(path)}-#{rrand}" do
        path "#{builddir}/#{File.dirname(path)}"
        owner "root"
        group "root"
        mode "0755"
        recursive true
      end

      file "#{builddir}/#{path}" do
        content "#{content}\n"
        owner "root"
        group "root"
        mode "0644"
      end
    end

    # fetch initial seed from main mirror
    directory "#{builddir}/initial" do
      owner "root"
      group "root"
      mode "0755"
      not_if { File.exist?("#{builddir}/.control/version") }
    end

    remote_file "#{builddir}/initial/#{build}-initial-#{arch}-stage3.tar.bz2" do
      source "http://mirror.zenops.net/zentoo/#{arch}/zentoo-amd64-stage3.tar.bz2"
      owner "root"
      group "root"
      not_if { File.exist?("#{builddir}/.control/version") }
    end

    # setup version control
    directory "#{builddir}/.control/version" do
      owner "root"
      group "root"
      mode "0755"
    end

    file "#{builddir}/.control/version/stage3" do
      content "initial\n"
      owner "root"
      group "root"
      mode "0644"
      not_if { File.exist?("#{builddir}/.control/version/stage3") }
    end

  end
end
