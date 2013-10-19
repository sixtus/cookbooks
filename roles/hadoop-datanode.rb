description "Hadoop Datanode"

run_list(%w(
  recipe[hadoop::datanode]
))
