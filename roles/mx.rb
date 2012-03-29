description "Mail Relay Server"

run_list(%w(
  role[base]
  recipe[postfix::relay]
))

override_attributes({
  "skip" => {
    "postfix_satelite" => true,
  },
})
