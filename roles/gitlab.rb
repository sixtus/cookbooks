description "GitLab"

run_list(%w(
  role[base]
  recipe[gitlab]
))
