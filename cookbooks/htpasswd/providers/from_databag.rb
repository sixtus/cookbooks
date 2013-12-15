def whyrun_supported?
  true
end

use_inline_resources

action :create do
  nr = new_resource

  users = data_bag_item('htpasswd', nr.bag).select do |user, password|
    user != "id"
  end

  htpasswd_file nr.path do
    content content
    owner nr.owner
    group nr.group
    mode nr.mode
    users users
  end
end

action :delete do
  nr = new_resource

  htpasswd_file nr.path do
    action :delete
  end
end
