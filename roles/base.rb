description "base role for all nodes"

run_list(%w(
  recipe[base]
  recipe[bash]
  recipe[git]
  recipe[htop]
  recipe[lftp]
  recipe[python]
  recipe[ssh]
  recipe[tmux]
  recipe[vim]
))
