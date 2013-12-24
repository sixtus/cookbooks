description "base role for all nodes"

run_list(%w(
  recipe[base]
  recipe[account]
  recipe[bash]
  recipe[cron]
  recipe[git]
  recipe[htop]
  recipe[lftp]
  recipe[lib_users]
  recipe[nss]
  recipe[openssl]
  recipe[postfix]
  recipe[python]
  recipe[ssh::server]
  recipe[sudo]
  recipe[syslog]
  recipe[tmux]
  recipe[vim]
))
