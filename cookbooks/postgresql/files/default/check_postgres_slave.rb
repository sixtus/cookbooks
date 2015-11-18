#!/usr/bin/env ruby

require 'nagios'
require 'pg'

class SlaveLag < Nagios::Plugin

  def initialize
    super

    @host = "localhost"
    @database = "madvertise_production"
    @user = "postgres"

    @config.options.on('--host=HOST', '-hHOST',
      'What host to use') {|host| @host = host}
    @config.options.on('--database=DATABASE', '-dDATABASE',
      'What database to use') {|database| @database = database}
    @config.options.on('--user=USER', '-uUSER',
      'What database user to use') {|user| @user = user}
    @config.options.on('--password=PASSWORD', '-pPASSWORD',
      'What password to use') {|password| @password = password}

    @config.parse!
  end

  def connection
    @connection ||= PG.connect host: @host, dbname: @database, user: @user, password: @password
  end

  protected

  def query(stmt)
    connection.exec(stmt)
  end


  def measure
    query("SELECT CASE WHEN pg_last_xlog_receive_location() = pg_last_xlog_replay_location() THEN 0 ELSE EXTRACT (EPOCH FROM now() - pg_last_xact_replay_timestamp()) END AS log_delay;").
      first.values_at("log_delay").first.to_i
  end

  def warning(m)
    m > threshold(:warning)
  end

  def critical(m)
    m > threshold(:critical)
  end

  def to_s(m)
    "#{m} seconds delay"
  end

end

SlaveLag.new.run!
