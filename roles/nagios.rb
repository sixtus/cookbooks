description "Nagios Server"

run_list(%w(
  role[base]
  recipe[nagios::server]
))
