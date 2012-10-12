description "Ceph Metadata Servers (MDS)"

run_list(%w(
  role[base]
  recipe[ceph::mds]
))
