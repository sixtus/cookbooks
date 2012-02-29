description "base role for all nodes"

run_list(%w(
  recipe[base]
  recipe[duply]
  recipe[postfix::satelite]
  recipe[chef::client]
))
