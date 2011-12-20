define :layman_overlay do
  include_recipe "portage"

  execute "layman -a #{params[:name]}" do
    creates "/var/lib/layman/#{params[:name]}"
    notifies :create, "ruby_block[update-packages-cache]", :immediately
  end
end
