description "Linux-VServer Host"

run_list(%w(
  role[base]
  recipe[vserver]
))
