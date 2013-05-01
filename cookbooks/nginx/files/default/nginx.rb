require 'open-uri'
require 'yajl'

collect do
  uri = "http://localhost:8031/metrics"
  status = Yajl::Parser.new(:symbolize_keys => true).parse(open(uri))

  Metriks.histogram('nginx.connections').update(status[:connections])
  Metriks.histogram('nginx.connections:reading').update(status[:reading])
  Metriks.histogram('nginx.connections:writing').update(status[:writing])
  Metriks.histogram('nginx.connections:waiting').update(status[:connections] - (status[:reading] + status[:writing]))
  Metriks.derive('nginx.requests').mark(status[:requests])

  status[:status_codes].each do |code, count|
    Metriks.derive("nginx.status:#{code}").mark(count)
  end
end
