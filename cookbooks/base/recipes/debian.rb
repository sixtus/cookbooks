if root?
  include_recipe "apt"

  link "/run" do
    to "/var/run"
  end

  link "/run/lock" do
    to "/var/lock"
  end

  gem_package "haml"
  gem_package "syslogger"
end
