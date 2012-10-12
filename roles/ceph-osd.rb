description "Ceph Object Storage Devices (OSD)"

run_list(%w(
  role[base]
  recipe[ceph::osd]
))
