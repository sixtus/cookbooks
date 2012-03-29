description "Backup Server"

run_list(%w(
  role[base]
  recipe[backup]
))
