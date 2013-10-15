require 'chef/provider/package'
require 'chef/mixin/command'
require 'chef/resource/package'
require 'chef/mixin/shell_out'

class Chef
  class Provider
    class Package
      class Apt < Chef::Provider::Package

        def sudo_prefix
          Process.euid == 0 ? "" : "/usr/bin/sudo -H "
        end

        def install_package(name, version)
          package_name = "#{name}=#{version}"
          package_name = name if @is_virtual_package
          run_command_with_systems_locale(
            :command => "#{sudo_prefix}apt-get -q -y#{expand_options(default_release_options)}#{expand_options(@new_resource.options)} install #{package_name}",
            :environment => {
              "DEBIAN_FRONTEND" => "noninteractive"
            }
          )
        end

        def remove_package(name, version)
          package_name = "#{name}"
          run_command_with_systems_locale(
            :command => "#{sudo_prefix}apt-get -q -y#{expand_options(@new_resource.options)} remove #{package_name}",
            :environment => {
              "DEBIAN_FRONTEND" => "noninteractive"
            }
          )
        end

        def purge_package(name, version)
          run_command_with_systems_locale(
            :command => "#{sudo_prefix}apt-get -q -y#{expand_options(@new_resource.options)} purge #{@new_resource.package_name}",
            :environment => {
              "DEBIAN_FRONTEND" => "noninteractive"
            }
          )
        end

        def preseed_package(preseed_file)
          Chef::Log.info("#{@new_resource} pre-seeding package installation instructions")
          run_command_with_systems_locale(
            :command => "#{sudo_prefix}debconf-set-selections #{preseed_file}",
            :environment => {
              "DEBIAN_FRONTEND" => "noninteractive"
            }
          )
        end

        def reconfig_package(name, version)
          Chef::Log.info("#{@new_resource} reconfiguring")
          run_command_with_systems_locale(
            :command => "#{sudo_prefix}dpkg-reconfigure #{name}",
            :environment => {
              "DEBIAN_FRONTEND" => "noninteractive"
            }
          )
        end

      end
    end
  end
end
