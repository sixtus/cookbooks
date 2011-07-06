#
# Rakefile for Chef Server Repository
#

require 'rubygems'
require 'chef'
require 'highline/import'

# load constants from rake config file.
require File.join(File.dirname(__FILE__), 'config', 'rake')

# load chef config
begin
  Chef::Config.from_file(File.join(File.dirname(__FILE__), '.chef', 'knife.rb'))
rescue
  # do nothing
end

Dir[ File.join(File.dirname(__FILE__), 'tasks', '*.rake') ].sort.each do |f|
  load f
end
