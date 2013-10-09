description "Splunk"

run_list(%w(
  role[base]
  recipe[splunk]
  recipe[splunk::web]
))
