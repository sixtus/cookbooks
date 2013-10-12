if root?
  include_recipe "apt"

  gem_package "haml"
  gem_package "syslogger"
end
