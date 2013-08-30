#!/usr/bin/env ruby

require 'net/http'
require 'nokogiri'
require 'json'

SEARCH_HOST = "<%= @search[:primary_ipaddress] rescue 'localhost' %>"
SEARCH_PORT = 8089
SEARCH_URI  = "https://#{SEARCH_HOST}:#{SEARCH_PORT}"
SEARCH_USER = "admin"
SEARCH_PASS = "<%= @master[:splunk][:pass4symmkey] rescue node[:splunk][:pass4symmkey] %>"

begin
  http = Net::HTTP.new(SEARCH_HOST, SEARCH_PORT)
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE

  # Login and get the session key
  req = Net::HTTP::Post.new('/servicesNS/admin/search/auth/login')
  req.set_form_data({
    username: SEARCH_USER,
    password: SEARCH_PASS,
  })

  res = http.request(req)

  if !res.is_a?(Net::HTTPSuccess)
    puts "login failed: #{res.inspect}"
    exit(2)
  end

  session_key = Nokogiri::XML(res.body).css('response sessionKey').first.text

  # Perform search
  req = Net::HTTP::Post.new('/servicesNS/admin/SplunkForNagios/search/jobs/export', {
    'Authorization' => "Splunk #{session_key}",
  })

  req.set_form_data({
    search: "| savedsearch #{ARGV.first}",
    output_mode: 'json',
    preview: 'false',
  })

  res = http.request(req)

  if !res.is_a?(Net::HTTPSuccess)
    puts "search failed: #{res.inspect}"
    exit(2)
  end

  # check values/ranges
  data = JSON.load(res.body)['result']
  range = data.delete('range')

  puts data.inspect

  if range == 'critical'
    exit(2)
  elsif range == 'warning'
    exit(1)
  end

  exit(0)
rescue => e
  puts "exception: #{e.message}, #{e.backtrace}"
  exit(2)
end
