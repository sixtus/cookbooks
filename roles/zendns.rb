description "ZenDNS node"

run_list(%w(
  role[base]
  recipe[zendns]
))
