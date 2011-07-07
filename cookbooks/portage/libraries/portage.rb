module Gentoo
  module Portage
    module PackageConf

      # Creates or deletes per package portage attributes. Returns true if it
      # changes (sets or deletes) something.
      # * action == :create || action == :delete
      # * conf_type =~ /\A(use|keywords|mask|unmask)\Z/
      def manage_package_conf(action, conf_type, name, package = nil, flags = nil)
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
        raise Chef::Exceptions::Package, "#{conf_type} should be a directory." unless ::File.directory?(conf_dir)

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

        ::File.open("#{conf_file}", "w") { |f| f << content + "\n" }
        Chef::Log.info("Created #{conf_file} \"#{content}\".")
        true
      end

      def delete_package_conf_file(conf_file)
        return nil unless ::File.exists?(conf_file)

        ::File.delete(conf_file)
        Chef::Log.info("Deleted #{conf_file}")
        true
      end
    end

    module Emerge
      include Gentoo::Portage::PackageConf

      # Memoize package info
      attr_accessor :package_info
      def package_info
        @package_info ||= package_info_from_eix(@new_resource.name)
      end

      def emerge_cmd(pkg, emerge_options = nil)
        "/usr/bin/emerge --color=n --nospinner --quiet #{emerge_options} #{pkg}"
      end

      # Sets portage attributes and then emerges the package only if necessary.
      def conditional_emerge(new_resource, action)
        package_data = package_info

        if package_data[:candidate_version].to_s == ""
          raise Chef::Exceptions::Package, "No candidate version available for #{new_resource.name}"
        end

        package_atom = "#{package_data[:category]}/#{package_data[:package_name]}"
        package_atom = "=#{package_atom}-#{new_resource.version}" if new_resource.version

        emerge(package_data[:package_atom], new_resource.options) if emerge?(action, package_data, new_resource.version)
      end


      private

      def emerge?(action, package_data, requested_version)
        version = requested_version.to_s

        # If we find no version, regardless of action emerge this package
        if package_data[:current_version] == ""
          Chef::Log.info("No version found. Installing package[#{package_data[:package_atom]}].")
          return true
        end

        case action
        when :install
          # If we requested any version, then do nothing
          return false if version == ""
          # If we have the same version, then do nothing
          return false if package_data[:current_version] == version

          Chef::Log.info("Installing package[#{package_data[:package_atom]}] (version requirements unmet).")
          true
        when :reinstall
          Chef::Log.info("Reinstalling package[#{package_data[:package_atom]}].")
          true
        when :upgrade
          # Do not upgrade if the version is the same.
          return false if package_data[:current_version] == package_data[:candidate_version]
          true
        else
          raise Chef::Exceptions::Package, "Unknown action :#{action}"
        end
      end

      # Emerges "package_atom" with additional "options".
      def emerge(package_atom, options)
        Chef::Mixin::Command.run_command_with_systems_locale(
          :command => emerge_cmd(package_atom, options)
        )
      end

      def full_package_atom(category, name, version = nil)
        package_atom = "#{category}/#{name}"
        return package_atom unless version

        if version =~ /^\~(.+)/
          # If we start with a tilde
          "~#{package_name}-#{$1}"
        else
          "=#{package_name}-#{version}"
        end
      end

      # Searches for "package_name" and returns a hash with parsed information
      # returned by eix.
      #
      #   # git is installed on the system
      #   package_info_from_eix("git")
      #   => {
      #        :category => "dev-vcs",
      #        :package_name => "git",
      #        :current_version => "1.6.3.3",
      #        :candidate_version => "1.6.4.4"
      #      }
      #   # git isn't installed
      #   package_info_from_eix("git")
      #   => {
      #        :category => "dev-vcs",
      #        :package_name => "git",
      #        :current_version => "",
      #        :candidate_version => "1.6.4.4"
      #      }
      #   package_info_from_eix("dev-vcs/git") == package_info_from_eix("git")
      #   => true
      #   package_info_from_eix("package/doesnotexist")
      #   => nil
      def package_info_from_eix(package_name)
        eix = "/usr/bin/eix"
        eix_update = "/usr/bin/eix-update"

        unless ::File.executable?(eix)
          raise Chef::Exceptions::Package, "You should install app-portage/eix for fast package searches."
        end

        # We need to update the eix database if it's older than the current portage
        # tree or the eix binary.
        unless ::FileUtils.uptodate?("/var/cache/eix", [eix, "/usr/portage/metadata/timestamp"])
          Chef::Log.debug("eix database outdated, calling `#{eix_update}`.")
          Chef::Mixin::Command.run_command_with_systems_locale(:command => eix_update)
        end

        query_command = [eix, "--nocolor", "--pure-packages", "--stable", "--exact",
          '--format "<category>\t<name>\t<installedversions:VERSION>\t<bestversion:VERSION>\n"',
          package_name.count("/") > 0 ? "--category-name" : "--name", package_name].join(" ")

        eix_out = eix_stderr = nil

        Chef::Log.debug("Calling `#{query_command}`.")
        status = Chef::Mixin::Command.popen4(query_command) do |pid, stdin, stdout, stderr|
          eix_stderr = stderr.read
          if stdout.read.split("\n").first =~ /\A(\S+)\t(\S+)\t(\S*)\t(\S+)\Z/
            eix_out = {
              :category => $1,
              :package_name => $2,
              :current_version => $3,
              :candidate_version => $4
            }
          end
        end

        eix_out ||= {}

        unless status.exitstatus == 0
          raise Chef::Exceptions::Package, "eix search failed: `#{query_command}`\n#{eix_stderr}\n#{status.inspect}!"
        end

        Chef::Log.debug("eix search for #{package_name} returned: category: \"#{eix_out[:category]}\", package_name: \"#{eix_out[:package_name]}\", current_version: \"#{eix_out[:current_version]}\", candidate_version: \"#{eix_out[:candidate_version]}\".")

        eix_out[:package_atom] = full_package_atom(eix_out[:category], eix_out[:package_name], new_resource.version)
        eix_out
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

          @current_resource.version(nil)

          _, category_with_slash, category, pkg = %r{^#{PACKAGE_NAME_PATTERN}$}.match(@new_resource.package_name).to_a

          possibilities = Dir["/var/db/pkg/#{category || "*"}/#{pkg}-*"].map {|d| d.sub(%r{/var/db/pkg/}, "") }
          versions = possibilities.map do |entry|
            if(entry =~ %r{[^/]+/#{Regexp.escape(pkg)}\-(\d[\.\d]*((_(alpha|beta|pre|rc|p)\d*)*)?(-r\d+)?)})
              [$&, $1]
            end
          end.compact

          if versions.size > 1
            if category
              @current_resource.version(versions.last.last)
            else
              atoms = versions.map {|v| v.first }.sort
              raise Chef::Exceptions::Package, "Multiple packages found for #{@new_resource.package_name}: #{atoms.join(" ")}. Specify a category."
            end
          elsif versions.size == 1
            @current_resource.version(versions.first.last)
          end

          Chef::Log.debug("#{@new_resource} current version #{$1}")

          @current_resource
        end

        def install_package(name, version)
          conditional_emerge(new_resource, :install)
        end

        def upgrade_package(name, version)
          conditional_emerge(new_resource, :upgrade)
        end

        def candidate_version
          @candidate_version ||= self.package_info[:candidate_version]
        end

      end
    end
  end
end
