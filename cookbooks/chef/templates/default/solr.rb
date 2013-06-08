# Configuration File For Chef SOLR Indexer (chef-solr-indexer)

require "madvertise-logging"

ImprovedLogger.class_eval do
  attr_accessor :sync, :formatter
end

log_level :warn
log_location ImprovedLogger.new(:syslog, "chef-solr")

solr_jetty_path "/var/lib/chef/solr/jetty"
solr_home_path "/var/lib/chef/solr/home"
solr_data_path "/var/lib/chef/solr/data"
solr_heap_size "256M"
solr_java_opts "-Djava.util.logging.config.file=/var/lib/chef/solr/home/conf/logging.properties"
