#
# Rakefile for Chef Server Repository
#

require 'rubygems'

begin
  require 'bundler'
rescue LoadError
  if Process.euid > 0
    $stderr.puts "Bundler could not be loaded. Please make sure to run ./scripts/bootstrap"
    exit(1)
  end
end

Bundler.setup if defined?(Bundler)

require 'chef'

# load constants from rake config file.
require File.expand_path('../config/rake', __FILE__)

# load chef config
begin
  Chef::Config.from_file(File.expand_path('../.chef/knife.rb', __FILE__))
rescue
  # do nothing
end

Dir[ File.join(File.dirname(__FILE__), 'tasks', '*.rake') ].sort.each do |f|
  load f
end
