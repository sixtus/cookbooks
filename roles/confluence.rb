description "Atlassian Confluence"

run_list(%w(
  recipe[mysql::server]
  recipe[confluence]
))

override_attributes({
  backup: {
    configs: {
      confluence: {
        source: "/var/lib/confluence",
      },
    },
  },

  mysql: {
    server: {
      binlog_format: 'row',
      max_allowed_packet: '64M',
    },
  },
})
