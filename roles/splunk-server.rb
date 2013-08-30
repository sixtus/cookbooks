description "Splunk Server (single instance)"

run_list(%w(
  role[splunk-peer]
  role[splunk-search]
))
