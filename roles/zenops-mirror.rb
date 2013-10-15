description "ZenOps Mirror and CI"

run_list(%w(
  recipe[zenops::mirror]
))
