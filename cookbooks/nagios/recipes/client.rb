include_recipe "nagios::nrpe"
include_recipe "nagios::nsca"

portage_package_keywords "dev-ruby/nagios"

package "dev-ruby/nagios"
