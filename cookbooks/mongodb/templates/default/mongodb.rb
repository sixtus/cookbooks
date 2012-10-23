require 'mongo'

collect do
  instance = "<%= @name %>"
  port = <%= @port %>

  connection = ::Mongo::Connection.new('localhost', port)
  admin = connection.db('admin')
  stats = admin.command({serverStatus: 1})

  Metriks.histogram("mongodb.#{instance}.connections").update(stats['connections']['current'])
  Metriks.histogram("mongodb.#{instance}.lock.ratio").update((stats['globalLock']['lockTime'].to_f / stats['globalLock']['totalTime'].to_f) * 100)
  Metriks.histogram("mongodb.#{instance}.queue:read").update(stats['globalLock']['currentQueue']['readers'])
  Metriks.histogram("mongodb.#{instance}.queue:write").update(stats['globalLock']['currentQueue']['writers'])

  %w(resident virtual mapped).each do |key|
    Metriks.histogram("mongodb.#{instance}.mem:#{key}").update(stats['mem'][key])
  end

  stats['opcounters'].each do |key, value|
    Metriks.derive("mongodb.#{instance}.ops:#{key}").mark(value)
  end

  stats['indexCounters']['btree'].each do |key, value|
    Metriks.derive("mongodb.#{instance}.btree:#{key}").mark(value)
  end
end
