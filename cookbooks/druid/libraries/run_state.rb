module DruidHelpers
  def druid_version
    @druid_version ||= mvn_project_version("/var/app/druid/current")
  end

  def druid_overlord_nodes(cluster_name = node.cluster_name)
    node.nodes.cluster(cluster_name).role("druid-overlord")
  end

  def druid_broker_nodes(cluster_name = node.cluster_name)
    node.nodes.cluster(cluster_name).role("druid-broker")
  end

  def druid_realtime_spec
    node[:druid][:sources].map do |source, config|
      next if config[:clusters] && !config[:clusters].include?(node.cluster_name)
      {
        dataSchema: {
          dataSource: source,
          parser: {
            type: "string",
            parseSpec: {
              format: "json",
              timestampSpec: {
                column: ((config[:timestamp] || {})[:column] || "ts"),
                format: ((config[:timestamp] || {})[:format] || "iso"),
              },
              dimensionsSpec: {
                dimensions: (config[:dimensions] || []),
              }
            },
          },
          metricsSpec: (config[:aggregators] || {}).map do |name, aggregator|
            { type: aggregator, name: name, fieldName: name }
          end + [{ type: "count", name: "events" }],
          granularitySpec: {
            type: "uniform",
            segmentGranularity: "hour",
            queryGranularity: (config[:granularity] || "minute"),
          },
        },
        ioConfig: {
          type: "realtime",
          firehose: {
            type: "kafka-0.8",
            consumerProps: {
              "group.id" => "druid-realtime_#{node[:cluster][:host][:group]}.#{node.cluster_name}_#{source}",
              "zookeeper.connect" => zookeeper_connect(node[:kafka][:zookeeper][:root], node[:kafka][:zookeeper][:cluster]),
              "zookeeper.session.timeout.ms" => "15000",
              "zookeeper.sync.time.ms" => "5000",
              "rebalance.max.retries" => "64",
              "auto.commit.enable" => "false",
              "fetch.message.max.bytes" => "1048576",
            },
            feed: source,
          },
          plumber: {
            type: "realtime",
          },
        },
        tuningConfig: {
          type: "realtime",
          maxRowsInMemory: 1000000,
          intermediatePersistPeriod: "PT10m",
          windowPeriod: "PT10m",
          basePersistDirectory: "/var/app/druid/storage/realtime/#{source}",
          rejectionPolicy: { type: "serverTime" },
          shardSpec: {
            type: "linear",
            partitionNum: node[:druid][:realtime][:partition],
          },
        },
      }
    end.compact
  end

  def druid_sources
    node[:druid][:sources].to_hash
  end
end

include DruidHelpers

class Chef
  class Recipe
    include DruidHelpers
  end

  class Node
    include DruidHelpers
  end

  class Resource
    include DruidHelpers
  end
end
