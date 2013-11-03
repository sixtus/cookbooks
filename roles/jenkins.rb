description "Jenkins Continuous Integration"

run_list(%w(
  recipe[mysql::server]
  recipe[firefox]
  recipe[jenkins]
))

override_attributes({
  jenkins: {
    server_name: "ci.zenops.net",
  },

  mysql: {
    server: {
      binlog_format: 'row',
      max_allowed_packet: '64M',
    },
  },
})
