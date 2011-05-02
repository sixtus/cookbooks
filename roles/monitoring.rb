description "Monitoring Servers"

run_list(%w(
  role[base]
  recipe[nagios::server]
))

default_attributes({
  "munin" => {
    "group" => "monitoring"
  },
})
