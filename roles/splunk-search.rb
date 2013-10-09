description "Splunk Search Head"

run_list(%w(
  role[splunk]
  recipe[splunk::search]
))
