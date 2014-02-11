#!/usr/bin/env ruby

require 'net/http'
require 'nokogiri'
require 'json'

SEARCH_HOST = "<%= @search[:primary_ipaddress] rescue 'localhost' %>"
SEARCH_PORT = 2047
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
  range = nil
  issue_counter = 0
  long_text = ""
  res.body.split("\n").each do |row|
    data = JSON.load(row)['result']


    row_range = data.delete('range')
    long_text << "#{row_range.upcase}: #{data.inspect}\n"

    if row_range == 'critical'
      issue_counter += 1
      range = row_range
    elsif row_range == 'warning'
      issue_counter += 1
      range = row_range unless range == 'critical'
    elsif range == nil
      range = row_range
    end
  end

  if range == nil
    puts "Splunk did not return a (valid) search result"
    puts res.body
    exit(2)
  elsif range == 'critical'
    puts "CRITICAL: #{issue_counter} value(s) not ok, click for details"
    puts long_text
    exit(2)
  elsif range == 'warning'
    puts "WARNING: #{issue_counter} value(s) not ok, click for details"
    puts long_text
    exit(1)
  else
    puts "OK: all values ok"
    puts long_text
    exit(0)
  end

rescue => e
  puts "exception: #{e.message}, #{e.backtrace}"
  exit(2)
end
