define :layman_overlay do
  include_recipe "portage"

  execute "layman -a #{params[:name]}" do
    creates "/var/lib/layman/#{params[:name]}"
    notifies :run, "execute[eix-update]", :immediately
  end
end
