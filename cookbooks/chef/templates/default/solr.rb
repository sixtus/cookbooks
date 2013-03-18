# Configuration File For Chef SOLR Indexer (chef-solr-indexer)

require "madvertise-logging"

ImprovedLogger.class_eval do
  attr_accessor :sync, :formatter
end

log_level :warn
log_location ImprovedLogger.new(:syslog, "chef-client")

search_index_path  "/var/lib/chef/search_index"

solr_jetty_path    "/var/lib/chef/solr/jetty"
solr_home_path     "/var/lib/chef/solr/home"
solr_data_path     "/var/lib/chef/solr/data"
solr_heap_size     "256M"

amqp_pass          "<%= @amqp_pass %>"
