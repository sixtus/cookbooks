require 'httparty'

class ZenDNS
  include HTTParty

  base_uri ZENDNS_API_URL
  default_params auth_token: ZENDNS_API_TOKEN, format: :json

  def self.domains
    JSON.parse(get("/domains"))
  end

  def self.records(domain_id)
    JSON.parse(get("/domains/#{domain_id}/records"))
  end

  def self.create_record(domain_id, record)
    response = post("/domains/#{domain_id}/records", body: {
      record: record
    }).response
    raise "failed to create record" unless response.is_a?(Net::HTTPOK)
  end
end
