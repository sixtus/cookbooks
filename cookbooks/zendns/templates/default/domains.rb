Settings[:domains] = {
  :nameserver => "<%= node[:zendns][:primary_nameserver] %>",
  :hostmaster => "<%= node[:contacts][:hostmaster] %>"
}
