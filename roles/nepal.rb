description "Nepal"

run_list(%w(
  role[base]
  recipe[nepal]
  recipe[mysql::backup]
))

override_attributes({
  :skip => {
    :postfix_satelite => true,
  },
})
