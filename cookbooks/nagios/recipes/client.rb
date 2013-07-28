include_recipe "nagios::nrpe"
include_recipe "nagios::nsca"

case node[:platform]
when "gentoo"
  package "dev-ruby/nagios" do
    action :remove
  end

  cookbook_file "/usr/lib/ruby/site_ruby/nagios.rb" do
    source "nagios.rb"
    owner "root"
    group "root"
    mode "0755"
  end

  directory "/usr/lib/ruby/site_ruby/nagios" do
    owner "root"
    group "root"
    mode "0755"
  end

  directory "/usr/lib/ruby/site_ruby/nagios/plugin" do
    owner "root"
    group "root"
    mode "0755"
  end

  cookbook_file "/usr/lib/ruby/site_ruby/nagios/plugin.rb" do
    source "plugin.rb"
    owner "root"
    group "root"
    mode "0755"
  end

when "debian"
  gem_package "nagios"
end
