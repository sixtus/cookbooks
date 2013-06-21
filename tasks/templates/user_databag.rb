comment "<%= name %>"
email "<%= email %>"
tags %w(<%= tags %>)

# <%= random %>
password "<%= password %>"
password1 "<%= password1 %>"

authorized_keys [
<% keys.each do |key| %>
"<%= key %>",
<% end %>
]
