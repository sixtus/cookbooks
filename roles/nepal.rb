description "Nepal"

run_list(%w(
  role[base]
  recipe[nepal]
))

override_attributes({
  :skip => {
    :postfix_satelite => true,
  },
})
