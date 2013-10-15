module Gentoo
  module Portage
    module PackageConf

      # Creates or deletes per package portage attributes. Returns true if it
      # changes (sets or deletes) something.
      # * action == :create || action == :delete
      # * conf_type =~ /\A(use|keywords|mask|unmask)\Z/
      def manage_package_conf(action, conf_type, name, package = nil, flags = nil)
        return unless root?
        conf_file = package_conf_file(conf_type, name)
        case action
        when :create
          create_package_conf_file(conf_file, normalize_package_conf_content(package, flags))
        when :delete
          delete_package_conf_file(conf_file)
        else
          raise Chef::Exceptions::Package, "Unknown action :#{action}."
        end
      end

      # Returns the portage package control file name:
      # =net-analyzer/nagios-core-3.1.2 => chef-net-analyzer-nagios-core-3-1-2
      # =net-analyzer/netdiscover => chef-net-analyzer-netdiscover
      def package_conf_file(conf_type, name)
        conf_dir = "/etc/portage/package.#{conf_type}"

        unless ::File.directory?(conf_dir)
          ::FileUtils.rm_rf(conf_dir)
          ::FileUtils.mkdir_p(conf_dir)
        end

        package_atom = name.strip.split(/\s+/).first
        package_file = package_atom.gsub(/[\/\.|]/, "-").gsub(/[^a-z0-9_\-]/i, "")
        return "#{conf_dir}/chef-#{package_file}"
      end

      # Normalizes package conf content
      def normalize_package_conf_content(name, flags = nil)
        [ name, normalize_flags(flags) ].join(' ')
      end

      # Normalizes String / Arrays
      def normalize_flags(flags)
        if flags.is_a?(Array)
          flags.sort.uniq.join(' ')
        else
          flags
        end
      end

      def same_content?(filepath, content)
        content.strip == ::File.read(filepath).strip
      end

      def create_package_conf_file(conf_file, content)
        return nil if ::File.exists?(conf_file) && same_content?(conf_file, content)

        if Process.euid == 0
          ::File.open(conf_file, "w") { |f| f << content + "\n" }
          Chef::Log.info("Created #{conf_file} \"#{content}\".")
        else
          Chef::Log.warn("skipping #{conf_file} in non-root mode")
        end
        true
      end

      def delete_package_conf_file(conf_file)
        return nil unless ::File.exists?(conf_file)

        if Process.euid == 0
          ::File.delete(conf_file)
          Chef::Log.info("Deleted #{conf_file}")
        else
          Chef::Log.warn("skipping #{conf_file} in non-root mode")
        end
        true
      end
    end

    module Emerge
      include Gentoo::Portage::PackageConf

      def package_info
        packages_cache_from_eix
        @@packages_cache[@new_resource.package_name].tap do |pkg|
          if pkg
            pkg.merge!({
              :package_atom => full_package_atom(@new_resource.package_name, @new_resource.version)
            })
          end
        end
      end

      def emerge(action)
        if package_info[:candidate_version].to_s == ""
          raise Chef::Exceptions::Package, "No candidate version available for #{@new_resource.name}"
        end

        if emerge?(action)
          sudo_prefix = Process.euid == 0 ? "" : "/usr/bin/sudo -H "
          Chef::Mixin::Command.run_command_with_systems_locale(
            :command => "#{sudo_prefix}/usr/bin/emerge --color=n --nospinner --quiet #{@new_resource.options} #{package_info[:package_atom]}"
          )
        end
      end

      def emerge?(action)
        version = @new_resource.version.to_s

        unless package_info[:current_version]
          Chef::Log.info("package[#{@new_resource.name}] installing #{package_info[:package_atom]}")
          return true
        end

        case action
        when :install
          return false if version == ""
          return false if package_info[:current_version] == version
          Chef::Log.info("package[#{@new_resource.name}] installing #{package_info[:package_atom]} (version requirements unmet)")
          true

        when :upgrade
          return false if package_info[:current_version] == package_info[:candidate_version]
          true

        else
          raise Chef::Exceptions::Package, "Unknown action: #{action}"
        end
      end

      def packages_cache_from_eix
        @@packages_cache ||= {}
        packages_cache_from_eix! if @@packages_cache.empty?
      end

      def packages_cache_from_eix!
        eix = "/usr/bin/eix"
        eix_update = "/usr/bin/eix-update"

        unless ::File.executable?(eix)
          raise Chef::Exceptions::Package, "You need to install app-portage/eix for fast package searches."
        end

        # We need to update the eix database if it's older than the current portage
        # tree or the eix binary.
        cache_file = if File.directory?("/var/cache/eix")
                       "/var/cache/eix/portage.eix"
                     else
                       "/var/cache/eix"
                     end

        unless ::FileUtils.uptodate?(cache_file, [eix, "/usr/portage/metadata/timestamp"])
          Chef::Log.debug("eix database outdated, calling `#{eix_update}`.")
          Chef::Mixin::Command.run_command_with_systems_locale(:command => eix_update)
        end

        query_command = [
          eix,
          "--nocolor",
          "--pure-packages",
          '--format "<category>/<name>\t<bestversion:PVERSION>\t<installedversions:PVERSION>\n"',
        ].join(" ")

        eix_stderr = nil
        @@packages_cache = {}

        Chef::Log.debug("Calling `#{query_command}`.")
        status = Chef::Mixin::Command.popen4(query_command) do |pid, stdin, stdout, stderr|
          eix_stderr = stderr.read
          stdout.readlines.each do |line|
            pn, candidate, current = line.split(/\t/)
            @@packages_cache[pn] = {
              :current_version => current.split(/\s/).last,
              :candidate_version => candidate,
            }
          end
        end

        unless status.exitstatus == 0
          raise Chef::Exceptions::Package, "eix search failed: `#{query_command}`\n#{eix_stderr}\n#{status.inspect}!"
        end
      end
      module_function :packages_cache_from_eix!

      def full_package_atom(package_atom, version = nil)
        return package_atom unless version

        if version =~ /^\~(.+)/
          "~#{package_atom}-#{$1}"
        else
          "=#{package_atom}-#{version}"
        end
      end

    end
  end
end

# monkeypatch Chefs package resource and portage provider
class Chef
  class Provider
    class Package
      class Portage < Chef::Provider::Package
        include ::Gentoo::Portage::Emerge

        def load_current_resource
          @current_resource = Chef::Resource::Package.new(@new_resource.name)
          @current_resource.package_name(@new_resource.package_name)

          if package_info and package_info[:current_version]
            @current_resource.version(package_info[:current_version])
          end

          @current_resource
        end

        def install_package(name, version)
          emerge(:install)
        end

        def upgrade_package(name, version)
          emerge(:upgrade)
        end

        def candidate_version
          @candidate_version ||= package_info[:candidate_version] rescue nil
        end

      end
    end
  end
end
