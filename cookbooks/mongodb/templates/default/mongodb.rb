require 'mongo'

collect do
  instance = "<%= @name %>"
  port = <%= @port %>

  connection = ::Mongo::Connection.new('localhost', port)
  admin = connection.db('admin')
  stats = admin.command({serverStatus: 1})

  sampler.emit(:gauge, "mongodb.#{instance}.connections", stats['connections']['current'])
  sampler.emit(:gauge, "mongodb.#{instance}.lock.ratio", stats['globalLock']['ratio'])
  sampler.emit(:gauge, "mongodb.#{instance}.queue.read", stats['globalLock']['currentQueue']['readers'])
  sampler.emit(:gauge, "mongodb.#{instance}.queue.write", stats['globalLock']['currentQueue']['writers'])

  %w(resident virtual mapped).each do |key|
    sampler.emit(:gauge, "mongodb.#{instance}.mem.#{key}", stats['mem'][key])
  end

  stats['opcounters'].each do |key, value|
    sampler.emit(:derive, "mongodb.#{instance}.ops.#{key}", value)
  end

  stats['indexCounters']['btree'].each do |key, value|
    sampler.emit(:derive, "mongodb.#{instance}.btree.#{key}", value)
  end
end
