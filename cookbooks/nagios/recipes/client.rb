include_recipe "nagios::nrpe"

directory "/usr/lib/ruby/site_ruby" do
  owner "root"
  group "root"
  mode "0755"
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

%w(
  plugin
  section
  status
).each do |f|
  cookbook_file "/usr/lib/ruby/site_ruby/nagios/#{f}.rb" do
    source "nagios/#{f}.rb"
    owner "root"
    group "root"
    mode "0755"
  end
end
