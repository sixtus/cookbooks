description "Backup Server"

run_list(%w(
  role[base]
  recipe[backup]
))

default_attributes({
  :munin => {
    :group => "backup",
  },
})
