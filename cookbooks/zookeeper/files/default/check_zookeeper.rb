#!/usr/bin/env ruby

require 'nagios'

module Status
  def command
    "ruok"
  end

  def measure
    get_status(@host)
  end

  def warning(m)
    false
  end

  def critical(m)
    m != "imok"
  end

  def to_s(m)
    "Zookeeper Status: #{m}"
  end
end

module ReadOnly
  def command
    "isro"
  end

  def measure
    get_status(@host)
  end

  def warning(m)
    false
  end

  def critical(m)
    m != "rw"
  end

  def to_s(m)
    "Zookeeper is #{m}"
  end
end

module Connections
  def key
    "zk_num_alive_connections"
  end

  def to_s(m)
    "#{m} connections"
  end
end

module Watches
  def key
    "zk_watch_count"
  end

  def to_s(m)
    "#{m} watches"
  end
end

module Nodes
  def key
    "zk_znode_count"
  end

  def to_s(m)
    "#{m} nodes"
  end
end

module Latency
  def key
    "zk_avg_latency"
  end

  def to_s(m)
    "latency: #{m}s"
  end
end

module Requests
  def key
    "zk_outstanding_requests"
  end

  def to_s(m)
    "#{m} outstanding requests"
  end
end

module Files
  def key
    "zk_open_file_descriptor_count"
  end

  def to_s(m)
    "#{m} open file descriptors"
  end
end

module Followers
  def command
    "mntr"
  end

  def warning(m)
    false
  end

  def critical(m)
    @leader = m.find do |n|
      n['zk_server_state'] == "leader"
    end

    @followers = m.select do |n|
      n['zk_server_state'] == "follower"
    end

    return true unless @leader

    @leader['zk_followers'].to_i != @followers.count or
    @leader['zk_synced_followers'].to_i != @followers.count
  end

  def to_s(m)
    "leader: #{@leader['hostname']} (" +
    "followers: #{@leader['zk_followers']}/#{@followers.count}, " +
    "synced: #{@leader['zk_synced_followers']}/#{@followers.count}" +
    "), followers: #{@followers.map {|n| n['hostname']}.join(',')}"
  end

  def measure
    @nodes.map do |node|
      stats_to_hash(get_status(node)).merge({
        'hostname' => node
      })
    end
  end
end

Class.new(Nagios::Plugin) do
  def initialize
    super

    @url   = []
    @nodes = []

    @config.options.on('-H', '--host=HOST',
                       'Zookeeper hostname') { |host| @host = host }
    @config.options.on('-n', '--node=URL',
                       'Zookeeper server nodes') { |node| @nodes << node }
    @config.options.on('-m', '--mode=MODE"',
                       'Zookeeper modes available') { |mode| @mode = mode }
    @config.parse!


    self.extend(Object.const_get(@mode))
  end

  def command
    "mntr"
  end

  def warning(m)
    m > threshold(:warning)
  end

  def critical(m)
    m > threshold(:critical)
  end

  def measure
    stats_to_hash(get_status(@host))[key].to_i
  end

  private

  def get_status(host)
    `echo '#{command}' | nc #{host} 2181 2> /dev/null`
  end

  def stats_to_hash(stats)
    Hash[stats.split("\n").map do |line|
      line.split("\t")
    end]
  end

end.run!
