description "Hadoop Jobtracker"

run_list(%w(
  recipe[hadoop::jobtracker]
))
