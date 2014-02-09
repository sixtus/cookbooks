description "Splunk 6 Server (single instance)"

run_list(%w(
  role[splunk6]
))
