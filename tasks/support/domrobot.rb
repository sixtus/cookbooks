require "xmlrpc/client"

module INWX
  class Domrobot
    attr_accessor :client, :cookie

    def initialize(address)
      @cookie = ""
      # Create a new client instance
      @client = XMLRPC::Client.new(address,"/xmlrpc/","443", nil, nil, nil, nil, true, 100)
    end
    
    def login(username = false, password = false, language = 'en')
      params = { :user => username, :pass => password, 'lang' => language }
      ret = call("account","login",params)
      cookie = client.cookie
      unless cookie.nil? || cookie.length <= 2
        setCookie(cookie)
      end
      return ret
    end
    
    def logout()
      call("account","logout")
    end
    
    def setCookie(cookie)
      self.cookie = cookie
      fp = File.new("domrobot.tmp", "w")
      fp.write(cookie)
      fp.close
    end
    
    def getCookie()
      if self.cookie.length > 2
        return self.cookie
      end
      if File.exist?("domrobot.tmp")
        fp = File.new("domrobot.tmp", "r")
        cookie = fp.read()
        fp.close
        return cookie
      end
    end
    
    def call(object, method, params = {})
      client.cookie = getCookie()
      # Call the remote method
      client.call(object+"."+method, params)
    end
  end
end

namespace :inwx do
  def domrobot
    unless @domrobot
      @domrobot = INWX::Domrobot.new($conf.inwx.addr)
      @domrobot.login($conf.inwx.user,$conf.inwx.token)
    end
    @domrobot
  end
end

def inwx_add_record(fqdn, ipaddress)
  return unless $conf.inwx.addr && $conf.inwx.user && $conf.inwx.token

  domain = $conf.inwx.domains.keys.select{|domain| fqdn.to_s.end_with? domain.to_s}[0]

  unless domain
    puts "Does not seem to be in INWX DNS..."
    return
  end

  query = {
    domain: domain, 
    type: "A",
    name: fqdn,
  }
  query_result = domrobot.call("nameserver", "info", query)

  fail "failed to query INWX" unless query_result['code'] == 1000

  records = [query_result['resData']['record']].flatten.compact

  records.each do |record|
    if record['type'] == 'CNAME'
      fail "#{fqdn} has an existing CNAME" 
    elsif record['type'] == "A"
      if record['content'] == ipaddress
        puts "Already set correctly"
        return
      else
        fail "Conflicting DNS record #{record}"
      end
    end
  end

  puts domrobot.call("nameserver", "createRecord", {
    domain: domain,
    type: "A",
    name: fqdn,
    content: ipaddress,
  })
end
