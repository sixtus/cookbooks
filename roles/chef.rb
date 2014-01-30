description "Chef Server"

run_list(%w(
  role[base]
  recipe[chef::server]
))
