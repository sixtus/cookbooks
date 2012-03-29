description "Syslog Server"

run_list(%w(
  role[base]
  recipe[syslog::server]
))
