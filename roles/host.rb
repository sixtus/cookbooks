description "Linux-VServer Hosts"

run_list(%w(
  role[base]
  recipe[vserver]
))
