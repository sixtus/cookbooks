#
# Rakefile for Chef Server Repository
#

require 'rubygems'

if Process.euid > 0
  begin
    require 'bundler'
  rescue LoadError
    $stderr.puts "Bundler could not be loaded. Please make sure to run ./scripts/bootstrap"
    exit(1)
  end

  Bundler.setup if defined?(Bundler)
end

require 'chef'

# load constants from rake config file.
require File.expand_path('../config/rake', __FILE__)

# load chef config
begin
  Chef::Config.from_file(KNIFE_CONFIG_FILE)
rescue
  # do nothing
end

Dir[ File.join(File.dirname(__FILE__), 'tasks', '*.rake') ].sort.each do |f|
  load f
end
