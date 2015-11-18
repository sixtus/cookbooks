#!/usr/bin/env ruby

require 'nagios'
require 'pg'
require 'yaml'

module ReplicationLag

  def measure
    apps = {}

    xlog_location = query("select pg_current_xlog_insert_location()").
      first.values_at("pg_current_xlog_insert_location").first

    query("select * from pg_stat_replication").each do |app_location|
      app_location, usename, client_addr, application_name = *app_location.values_at("flush_location", "usename", "client_addr", "application_name")

      diff = query("select * from pg_xlog_location_diff(\'#{xlog_location}\', \'#{app_location}\')").
        first.values_at("pg_xlog_location_diff").first

      # We use user- / app-name as a label, until we migrate to 9.5
      # (see: https://github.com/2ndQuadrant/bdr/issues/41)
      apps["#{application_name}(#{usename})@#{client_addr || 'localhost'}"] = diff.to_i / 1024 / 1024
    end

    apps
  end

  def warning(m)
    m.values.select{ |val| val > threshold(:warning) }.any?
  end

  def critical(m)
    m.values.select{ |val| val > threshold(:critical) }.any?
  end

  def to_s(m)
    m.to_yaml
  end

end

Class.new(Nagios::Plugin) do
  def initialize
    super

    @config.options.on('-m', '--mode=MODE',
      'Mode to use (ReplicationLag, ...)') { |mode| @mode = mode }
    @config.options.on('--host=HOST', '-hHOST',
      'What host to use') {|host| @host = host}
    @config.options.on('--database=DATABASE', '-dDATABASE',
      'What database to use') {|database| @database = database}
    @config.options.on('--user=USER', '-uUSER',
      'What database user to use') {|user| @user = user}
    @config.options.on('--password=PASSWORD', '-pPASSWORD',
      'What password to use') {|password| @password = password}

    @config.parse!
    raise "No mode given" unless @mode

    self.extend(Object.const_get(@mode.to_sym))
  end

  def connection
    @connection ||= PG.connect host: @host, dbname: @database, user: @user, password: @password
  end

  protected

  def query(stmt)
    connection.exec(stmt)
  end
end.run!
