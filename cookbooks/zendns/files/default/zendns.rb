collect do
  stats = Hash[%x(pdns_control show '*').chomp.split(/,/).map do |item|
    item.split(/=/)
  end.map do |k, v|
    [k, v.to_i]
  end]

  Metriks.derive("zendns.queries:tcp").mark(stats['tcp-queries'])
  Metriks.derive("zendns.queries:udp").mark(stats['udp-queries'])
  Metriks.derive("zendns.answers:tcp").mark(stats['tcp-answers'])
  Metriks.derive("zendns.answers:udp").mark(stats['udp-answers'])

  Metriks.histogram("zendns.cache.packets:hit").update(stats['packetcache-hit'])
  Metriks.histogram("zendns.cache.packets:miss").update(stats['packetcache-miss'])

  Metriks.histogram("zendns.cache.queries:hit").update(stats['query-cache-hit'])
  Metriks.histogram("zendns.cache.queries:miss").update(stats['query-cache-miss'])

  Metriks.histogram("zendns.latency").update(stats['latency'])
end
