define :nginx_module, :action => :create, :template => nil, :auto => true do
  include_recipe "nginx"

  suffix = params[:auto] ? "conf" : "include"

  template "/etc/nginx/modules/#{params[:name]}.#{suffix}" do
    action params[:action]
    source params[:template]
    owner "root"
    group "root"
    mode "0644"
    variables :params => params
    notifies :reload, "service[nginx]"
  end
end
