include_recipe "gobblin::base"

systemd_unit "gobblin@.service" do
  template true
end

node[:gobblin][:topics].each do |config|
  kafka_cluster, topic = config.split('/')

  safe_name = config.gsub(/[@.\/\\]/,'_')
  cluster = kafka_cluster.split('.')[-1]
  user = cluster.gsub(/\d/,'')

  config_content = %Q{# chef generated, do not edit
mapreduce.job.queuename=#{user}
job.name=#{safe_name}
job.group=GobblinKafka
job.description=Gobblin for #{safe_name}
job.lock.enabled=true
job.commit.policy=full

kafka.brokers=#{kafka_connect(kafka_cluster)}
topic.whitelist=#{topic}

bootstrap.with.offset=latest
reset.on.offset.out.of.range=nearest

source.class=gobblin.source.extractor.extract.kafka.KafkaSimpleSource
extract.limit.enabled=true
extract.limit.time.limit.timeunit=minutes
extract.limit.time.limit=50
extract.limit.type=time
extract.namespace=gobblin.extract.kafka

simple.writer.delimiter=\\n
writer.builder.class=gobblin.writer.GZIPDataWriterBuilder
writer.destination.type=HDFS
writer.file.path.type=tablename
writer.include.record.count.in.file.names=true
writer.output.format=events.gz
writer.partition.pattern=yyyy/MM/dd/HH
writer.partition.timezone=UTC
writer.partitioner.class=gobblin.writer.partitioner.TimeBasedJsonWriterPartitioner

data.publisher.type=gobblin.publisher.TimePartitionedDataPublisher

mr.job.max.mappers=10

fs.uri=hdfs://#{node[:hadoop2][:cluster]}/
writer.fs.uri=hdfs://#{node[:hadoop2][:cluster]}/
state.store.fs.uri=hdfs://#{node[:hadoop2][:cluster]}/

mr.job.root.dir=/gobblin/work/#{safe_name}
state.store.dir=/gobblin/state-store/#{safe_name}
task.data.root.dir=/gobblin/task/#{safe_name}
data.publisher.final.dir=/history/#{kafka_cluster}
}

  file "/var/app/gobblin/shared/config/#{safe_name}.properties" do
    owner "gobblin"
    group "gobblin"
    mode "0444"
    content config_content
    action :create
  end

  systemd_timer "gobblin@#{safe_name}" do
    schedule %w(OnBootSec=60 OnUnitInactiveSec=300)
    action :delete unless node[:gobblin][:active]
  end
end
