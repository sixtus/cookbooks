description "Splunk Indexer Peer"

run_list(%w(
  role[splunk]
  recipe[splunk::indexer]
))
