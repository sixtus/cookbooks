description "Ceph Monitor Servers"

run_list(%w(
  role[base]
  recipe[ceph::mon]
))
