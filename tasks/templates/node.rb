chef_environment "production"

set[:primary_ipaddress] = "<%= args.ipaddress %>"

run_list(%w(
<% if args.role != 'base' %>
  role[base]
<% end %>
  role[<%= args.role %>]
))

