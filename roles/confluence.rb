description "Atlassian Confluence"

run_list(%w(
  recipe[mysql::server]
  recipe[confluence]
))
