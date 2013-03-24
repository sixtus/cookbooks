description "OpenERP"

run_list(%w(
  role[base]
  recipe[openerp]
))
