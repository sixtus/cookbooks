define :ganymed_collector do
  next unless ganymed?
  include_recipe "ganymed"

  if variables = params[:variables]
    template "/usr/lib/ganymed/collectors/#{params[:name]}.rb" do
      source params[:source]
      owner "root"
      group "root"
      mode "0644"
      notifies :restart, 'service[ganymed]'
      variables variables
    end
  else
    cookbook_file "/usr/lib/ganymed/collectors/#{params[:name]}.rb" do
      source params[:source]
      owner "root"
      group "root"
      mode "0644"
      notifies :restart, 'service[ganymed]'
    end
  end
end
