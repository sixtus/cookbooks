#!/usr/bin/env ruby

require 'google/api_client'
require 'json'
require 'nagios'

Class.new(Nagios::Plugin) do
  def measure
    missing_days.length
  end

  def critical(m)
    m > 0
  end

  def warning(m)
  end

  def to_s(m)
    if critical(m)
      "Nobody signed up for #{stringify_dates(missing_days)} monitoring"
    else
      "All upcoming monitoring slots are taken!"
    end
  end

  private

  def missing_days
    @missing_days ||= check_range.to_a - get_taken_days.to_a
  end

  def get_taken_days
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

    result = client.execute({
      api_method: service.events.list,
      parameters: {
        calendarId: "<%= node[:nagios][:calendar][:calendar_id] %>",
        timeMin: (check_range.first).rfc3339,
        timeMax: (check_range.last+1).rfc3339,
      }
    })

    JSON.parse(result.response.body)["items"].map { |h| Date.parse(h["start"].values[0]) }
  end

  def check_range
    from = Date.today 
    to = Date.today.friday? ? Date.today + 3 : Date.today + 1
    (from..to)
  end

  def stringify_dates(dates_array)
    dates_array.map! do |date|
      days_array[date.wday]
    end

    last_day = dates_array.pop 

    if dates_array.length > 0
      string = dates_array.join(", ")
      string + " and #{last_day}"
    else
      last_day
    end
  end

  def days_array
    ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
  end
end.run!
