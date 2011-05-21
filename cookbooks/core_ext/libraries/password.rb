require "openssl"
require "fileutils"

module ChefUtils
  module Password
    def secure_random(length = 42)
      r = ""
      r << ::OpenSSL::Random.random_bytes(1).gsub(/\W/, '') while r.length < length
    end

    def get_password(key, length = 42)
      # we don't persist the password if node[:password][:directory] is unset
      return secure_random(length) if node[:password][:directory].to_s == ""

      password_file = File.expand_path(
        key.gsub(/[^a-z0-9\.\-\_\/]/i, "_").sub(/^\.+/, '_'),
        node[:password][:directory]
      )

      if ::File.size?(password_file)
        ::File.read(password_file).strip
      else
        password = secure_random(length)
        dir = ::File.dirname(password_file)
        ::FileUtils.mkdir_p(dir, :mode => 0700)
        ::File.open(password_file, "w") do |f|
          f.chmod(0600)
          f.puts(password)
        end
        password
      end
    end
  end
end

class Chef::Recipe
  include ChefUtils::Password
end
