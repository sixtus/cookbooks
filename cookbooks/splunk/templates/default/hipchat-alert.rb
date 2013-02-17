#!/usr/bin/env ruby
# encoding: utf-8

require "net/http"
require "uri"
require "haml"

def hipchat_send(auth_token, data)
  uri = URI.parse("https://api.hipchat.com/v1/rooms/message?auth_token=#{auth_token}")

  http = Net::HTTP.start(uri.host, uri.port, use_ssl: true)

  req = Net::HTTP::Post.new(uri.request_uri)
  req.set_form_data(data)

  http.request(req)
end

auth_token = "<%= node[:hipchat][:auth_token] %>"
room_id = "<%= node[:hipchat][:room_id] %>"
from = "Splunk"
color = "red"

message = Haml::Engine.new(DATA.read).render(binding)

hipchat_send(auth_token, {
  room_id: room_id,
  from: from,
  message: message,
  color: color,
})

__END__
%strong
  %a{href: ARGV[5]}= ARGV[3]
%br/
Reason: #{ARGV[4]}
