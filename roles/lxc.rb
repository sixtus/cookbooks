description "Linux Containers"

run_list(%w(
  role[base]
  recipe[lxc]
))
