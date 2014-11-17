#!/usr/bin/env ruby

require 'net/http'
require 'json'

SEARCH_HOST = "<%= @search[:ipaddress] rescue 'localhost' %>"
SEARCH_PORT = 8089

begin
  http = Net::HTTP.new(SEARCH_HOST, SEARCH_PORT)
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE

  # Perform search
  req = Net::HTTP::Post.new("/servicesNS/admin/#{ARGV[0]}/search/jobs/export")
  req.set_form_data({
    search: "| savedsearch #{ARGV[1]}",
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
  criticals = ""
  warnings = ""
  oks = ""

  res.body.split("\n").each do |row|
    data = JSON.load(row)['result']
    row_range = data.delete('range') rescue nil
    row_info = "#{row_range.upcase rescue "UNKNOWN"}: #{data.inspect}\n"

    if row_range == 'critical'
      criticals += row_info
      range = row_range
    elsif row_range == 'warning'
      warnings += row_info
      range = row_range unless range == 'critical'
    else
      oks += row_info
      range ||= row_range
    end
  end

  if range == nil
    puts "Splunk did not return a (valid) search result"
    puts res.body
    exit(2)
  end

  puts "#{criticals}#{warnings}#{oks}"

  if range == 'critical'
    exit(2)
  elsif range == 'warning'
    exit(1)
  else
    exit(0)
  end

rescue => e
  puts "exception: #{e.message}, #{e.backtrace}"
  exit(2)
end
