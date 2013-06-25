chef_environment "production"

set[:primary_ipaddress] = "<%= ipaddress %>"

run_list(%w(
<% if ENV['ROLE'] != 'base' %>
  role[base]
<% end %>
<% if ENV['ROLE'] %>
  role[<%= ENV['ROLE'] %>]
<% end %>
))

