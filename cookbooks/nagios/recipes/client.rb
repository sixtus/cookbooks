include_recipe "nagios::nrpe"
include_recipe "nagios::nsca"

case node[:platform]
when "gentoo"
  portage_package_keywords "dev-ruby/nagios"
  package "dev-ruby/nagios"

when "debian"
  gem_package "nagios"
end
