define :sudo_rule, host: "ALL", runas: "ALL" do
  if params[:command].kind_of?(String)
    params[:command] = [params[:command]]
  end
  params[:command] = params[:command].join(", ")
  node.set[:sudo][:rules][params[:name]] = params
end
