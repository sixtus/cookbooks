description "Splunk Server (single instance)"

run_list(%w(
  role[splunk]
  recipe[splunk::indexer]
  recipe[splunk::search]
))
