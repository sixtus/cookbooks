# Configuration File For Chef (chef-client)

node_name "<%= node[:fqdn] %>"

require "madvertise-logging"

ImprovedLogger.class_eval do
  attr_accessor :sync, :formatter
end

log_level :info
log_location ImprovedLogger.new(:syslog, "chef-client")

verbose_logging false
enable_reporting false

ssl_verify_mode :verify_none
chef_server_url "<%= node[:chef][:client][:server_url] %>"

file_cache_path "/var/lib/chef/cache"
file_backup_path "/var/lib/chef/backup"

<% if node[:chef][:client][:airbrake][:key] and ['production', 'staging'].include?(node.chef_environment) %>
require "airbrake_handler"
exception_handlers << AirbrakeHandler.new(:api_key => "<%= node[:chef][:client][:airbrake][:key] %>", :notify_host => "<%= node[:chef][:client][:airbrake][:url] %>" )
<% end %>

require 'chef/handler'
require 'fileutils'

class Chef
  class Handler
    class TerseFileHandler < ::Chef::Handler

      attr_reader :config

      def initialize(config={})
        @config = config
        @config[:path] ||= "/run/chef-client.stamp"
        @config
      end

      def report
        FileUtils.touch(@config[:path])
      end

    end
  end
end

report_handlers << Chef::Handler::TerseFileHandler.new
