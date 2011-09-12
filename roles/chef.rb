description "Chef Servers"

run_list(%w(
  role[base]
  recipe[chef::server]
  recipe[portage::binhost]
  recipe[openssl::certmaster]
))

default_attributes({
  "munin" => {
    "group" => "chef"
  },
})
