require 'open-uri'

collect do
  status = open("http://localhost:8031").read.split("\n")

  active = status[0].split[2].to_i
  accepts, handled, requests = status[2].split.map(&:to_i)
  _, reading, _, writing, _, waiting = status[3].split.map

  sampler.emit(:gauge, 'nginx.connections.reading', active)
  sampler.emit(:gauge, 'nginx.connections.writing', active)
  sampler.emit(:gauge, 'nginx.connections.waiting', active)
  sampler.emit(:derive, 'nginx.requests', requests)
end
