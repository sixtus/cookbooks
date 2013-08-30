description "Splunk Master"

run_list(%w(
  role[splunk]
  recipe[splunk::syslog]
))
