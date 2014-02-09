description "Splunk 6 Indexer Peer"

run_list(%w(
  role[splunk6]
))
