package "app-cdr/cdrtools"
package "app-emulation/virtualbox"
package "dev-python/boto"
package "sys-boot/syslinux"
package "sys-fs/squashfs-tools"

git "/usr/local/metro" do
  repository node[:metro][:repository]
  action :sync
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

    # fetch initial seed from zentoo.org
    directory "#{builddir}/initial" do
      owner "root"
      group "root"
      mode "0755"
      not_if { File.exist?("#{builddir}/.control/version") }
    end

    remote_file "#{builddir}/initial/stage3-#{arch}-#{build}-initial.tar.bz2" do
      source "http://www.zentoo.org/downloads/#{arch}/stage3-current.tar.bz2"
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

    if tagged?("nagios-client")
      nagios_plugin "check_metro_builds"

      nrpe_command "check_metro_#{build}_#{arch}" do
        command "/usr/lib/nagios/plugins/check_metro_builds #{builddir}"
      end

      nagios_service "METRO-#{build.upcase}-#{arch.upcase}" do
        check_command "check_nrpe!check_metro_#{build}_#{arch}"
        env [:testing, :development]
      end
    end
  end
end

# setup weekly build
builds = node[:metro][:builds].map do |build|
  node[:metro][:archs].map do |arch|
    "#{build}:#{arch}"
  end
end.flatten.join(' ')

cron_weekly "metro" do
  command "exec /usr/local/metro/scripts/ezbuild.sh #{builds}"
end
