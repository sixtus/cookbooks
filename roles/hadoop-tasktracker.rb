description "Hadoop Tasktracker"

run_list(%w(
  recipe[hadoop::tasktracker]
))
