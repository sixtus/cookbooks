#!/usr/bin/env ruby

require 'nagios'
require 'time'
require 'open-uri'
require 'yajl'

module NameNode
  def bean
    "Hadoop:service=NameNode,name=NameNodeInfo"
  end

  def critical(m)
    parse(m[:DeadNodes]).any? or
    parse(m[:DecomNodes]).any? or
    parse(m[:NameDirStatuses])[:failed].any?
  end

  def to_s(m)
    "DeadNodes: #{m[:DeadNodes]}, DecomNodes: #{m[:DecomNodes]}, NameDirStatuses: #{m[:NameDirStatuses]}"
  end
end

module Dfs
  def bean
    "Hadoop:service=NameNode,name=FSNamesystemState"
  end

  def critical(m)
    m[:FSState] != "Operational"
  end

  def to_s(m)
    "HDFS is #{m[:FSState]}"
  end
end

module DfsCapacity
  def bean
    "Hadoop:service=NameNode,name=NameNodeInfo"
  end

  def warning(m)
    m[:PercentUsed] > threshold(:warning).to_f
  end

  def critical(m)
    m[:PercentUsed] > threshold(:critical).to_f
  end

  def to_s(m)
    "PercentUsed: #{m[:PercentUsed]}%"
  end
end

module DfsBlocks
  def bean
    "Hadoop:service=NameNode,name=FSNamesystemMetrics"
  end

  def warning(m)
    m[:UnderReplicatedBlocks] > threshold(:warning).to_i
  end

  def critical(m)
    m[:UnderReplicatedBlocks] > threshold(:critical).to_i or
    [m[:MissingBlocks], m[:CorruptBlocks]].map(&:to_i).max > 0
  end

  def to_s(m)
    "TotalBlocks: #{m[:BlocksTotal]}, MissingBlocks: #{m[:MissingBlocks]}, CorruptBlocks: #{m[:CorruptBlocks]}, UnderReplicatedBlocks: #{m[:UnderReplicatedBlocks]}"
  end
end

module RpcQueue
  def bean
    "Hadoop:service=NameNode,name=RpcActivityForPort9000"
  end

  def warning(m)
    m[:RpcQueueTime_avg_time] > threshold(:warning).to_f
  end

  def critical(m)
    m[:RpcQueueTime_avg_time] > threshold(:critical).to_f
  end

  def to_s(m)
    "QueueTime: #{m[:RpcQueueTime_avg_time]}, ProcessingTime: #{m[:RpcProcessingTime_avg_time]}"
  end
end

module DataNode
  def bean
    "Hadoop:service=DataNode,name=FSDatasetState-DS-*"
  end

  def percent_used(m)
    (m[:DfsUsed].to_f / m[:Capacity].to_f * 100).round
  end

  def warning(m)
    percent_used(m) > threshold(:warning).to_f
  end

  def critical(m)
    percent_used(m) > threshold(:critical).to_f
  end

  def to_s(m)
    "PercentUsed: #{percent_used(m)}%"
  end
end

Class.new(Nagios::Plugin) do
  def initialize
    super

    @config.options.on('-m', '--mode=MODE',
      'Mode to use (pubsub, ad_provider_times, ...)') { |mode| @mode = mode }
    @config.options.on('-u', '--url=URL',
      'Which URL to query for stats') { |url| @url = url}

    @config.parse!
    raise "No mode given" unless @mode
    raise "No URL given" unless @url

    self.extend(Object.const_get(@mode.to_sym))
  end

  def warning(m)
    false
  end

  def parse(json)
    Yajl::Parser.new(:symbolize_keys => true).parse(json)
  end

  def measure
    @stats ||= parse(open(@url))[:beans].select do |obj|
      obj[:name] =~ Regexp.new(bean)
    end.first
  end
end.run!
