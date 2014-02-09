description "Splunk 6"

run_list(%w(
  role[base]
  recipe[splunk6]
  recipe[splunk6::web]
))
