#!/usr/bin/env ruby

require 'google/api_client'
require 'json'
require 'nagios'

Class.new(Nagios::Plugin) do

  attr_accessor :today

  def measure
    calendar.size
  end

  def critical(m)
    @today.friday? ? m < 2 : m == 0
  end

  def warning(m)
  end

  def to_s(m)
    if critical(m)
      "Nobody signed up for monitoring #{(@today.friday? ? "during one of the weekend days" : "for tommorow")}!"
    else
      "Monitoring slot for tomorrow is taken!"
    end
  end

  private

  def calendar
    client = Google::APIClient.new({ application_name: "CalendarClient", application_version: "0.0.1" })

    client.authorization.scope = "<%= node[:nagios][:calendar][:scope] %>"
    client.authorization.client_id = "<%= node[:nagios][:calendar][:client_id] %>"
    client.authorization.client_secret = "<%= node[:nagios][:calendar][:client_secret] %>"
    client.authorization.refresh_token = "<%= node[:nagios][:calendar][:refresh_token] %>"
    client.authorization.access_token = "<%= node[:nagios][:calendar][:access_token] %>"

    if client.authorization.refresh_token && client.authorization.expired?
      client.authorization.fetch_access_token!
    end

    service = client.discovered_api('calendar', 'v3')

    @today = Date.today
    tommorow = @today + 1
    check_days = tommorow + (@today.friday? ? 2 : 1)

    result = client.execute({
      api_method: service.events.list,
      parameters: {
        calendarId: "<%= node[:nagios][:calendar][:calendar_id] %>",
        timeMax: (check_days).rfc3339,
        timeMin: (tommorow).rfc3339
      }
    })

    items = JSON.parse(result.response.body)["items"]
  end

end.run!
