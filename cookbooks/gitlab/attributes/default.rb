default[:gitlab][:host] = "lab.#{node[:chef_domain]}"
default[:gitlab][:email_from] = node[:contacts][:hostmaster]
default[:gitlab][:support_email] = node[:contacts][:hostmaster]

# unicorn config
default[:gitlab][:unicorn][:worker_processes] = 4
default[:gitlab][:unicorn][:timeout] = 30
