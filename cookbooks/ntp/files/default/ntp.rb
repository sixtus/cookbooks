collect do
  output = %x(/usr/lib/nagios/plugins/check_ntp_time -H pool.ntp.org).chomp
  offset = output.
    split('|').last.
    split(';').first.
    split('=').last.
    chomp('s').
    to_f

  Metriks.histogram('ntp.offset').update(offset)
end
