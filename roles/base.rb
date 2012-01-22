description "base role for all nodes"

run_list(%w(
  recipe[base]
  recipe[syslog::client]
  recipe[cron]
  recipe[sudo]
  recipe[ssh]
  recipe[duply]
  recipe[postfix::satelite]
  recipe[chef::client]
  recipe[nagios::client]
  recipe[munin::node]
))
