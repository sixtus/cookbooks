#!/usr/bin/env ruby

require 'nagios'
require 'time'

class LastSuccessfulImport < Nagios::Plugin
  def measure
    raw = %x{/opt/hadoop/bin/hadoop fs -ls /events/*/*/*/*/_SUCCESS | sort -k 8 | tail -1}
    Time.now - Time.parse(raw.split(' ')[5..6].join(' '))
  end

  def warning(m)
    m > 1800 #30min
  end

  def critical(m)
    m > 3600 #60min
  end

  def to_s(m)
    "last successful import #{m / 60 / 60.0}h ago"
  end
end

LastSuccessfulImport.run!
