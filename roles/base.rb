description "base role for all nodes"

run_list(%w(
  recipe[base]
  recipe[duply]
))
