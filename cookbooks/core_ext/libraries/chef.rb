begin
  require 'chef/platform/service_helpers'

  class Chef
    class Platform
      class ServiceHelpers
        class << self
          def platform_has_systemd_unit?(service_name)
            shell_out!("#{systemctl_path} status #{service_name}")
          rescue Mixlib::ShellOut::ShellCommandFailed
            false
          end
        end
      end
    end
  end
rescue LoadError
  # do nothing
end

class Chef
  class Node

    # implemented in chef as run_list.include?("role[#{role_name}]") which does
    # not find expanded roles *facepalm*
    def role?(role_name)
      run_list.include?("role[#{role_name}]") or (self[:roles] and self[:roles].include?(role_name))
    end

    def cluster_name
      if self[:cluster] and self[:cluster][:name]
        self[:cluster][:name]
      else
        self[:fqdn]
      end
    end

    def cluster_domain
      if self[:cluster] and self[:cluster][:domain]
        self[:cluster][:domain]
      else
        nil
      end
    end

    def clustered?
      cluster_name != self[:fqdn]
    end

    def cluster?(name)
      name ? cluster_name == name : true
    end

  end

end
