if root?
  include_recipe "apt"

  link "/run" do
    to "/var/run"
    not_if { File.directory?("/run") }
  end

  link "/run/lock" do
    to "/var/lock"
    not_if { File.directory?("/run/lock") }
  end

  gem_package "haml"
  gem_package "syslogger"
end
