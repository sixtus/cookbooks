description "Splunk Indexer"

run_list(%w(
  role[base]
  recipe[splunk::indexer]
))
