#!/usr/bin/env ruby

require 'nagios'
require 'time'
require 'uri'
require 'yajl'
require 'net/http'

class Nagios::Plugin
  class Jolokia < Nagios::Plugin
    def initialize
      super
      @config.options.on('-m', '--module=MODULE', 'Module to use') { |m| @module = m }
      @config.options.on('-u', '--url=URL', 'Jolokia base URL') { |url| @url = url}
      @config.parse!
      raise "No URL given" unless @url
      self.extend(Object.const_get(@module.to_sym)) if @module
    end

    def warning(m)
      false
    end

    def parse(json)
      Yajl::Parser.new(symbolize_keys: true).parse(json)
    end

    def get_bean
      uri = URI("#{@url}/read")
      req = Net::HTTP::Post.new(uri.path, initheader = {'Content-Type' =>'application/json'})
      req.body = Yajl::Encoder.encode({type: "read", mbean: bean, attribute: attribute})
      response = Net::HTTP.new(uri.hostname, uri.port).start { |http| http.request(req) }
      parse(response.body)[:value]
    end

    def measure
      @value ||= get_bean
    end
  end
end
