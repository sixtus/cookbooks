# Configuration File For Chef Expander

require "madvertise-logging"

ImprovedLogger.class_eval do
  attr_accessor :sync, :formatter
end

log_level :warn
log_location ImprovedLogger.new(:syslog, "chef-expander")

amqp_pass "<%= @amqp_pass %>"
