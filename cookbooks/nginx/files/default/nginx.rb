require 'open-uri'

collect do
  status = open("http://localhost:8031").read.split("\n")

  active = status[0].split[2].to_i
  accepts, handled, requests = status[2].split.map(&:to_i)
  _, reading, _, writing, _, waiting = status[3].split

  Metriks.histogram('nginx.connections').update(active.to_i)
  Metriks.histogram('nginx.connections:reading').update(reading.to_i)
  Metriks.histogram('nginx.connections:writing').update(writing.to_i)
  Metriks.histogram('nginx.connections:waiting').update(waiting.to_i)
  Metriks.derive('nginx.requests').mark(requests)
end
