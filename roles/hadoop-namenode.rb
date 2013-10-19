description "Hadoop Namenode"

run_list(%w(
  recipe[hadoop::namenode]
))
