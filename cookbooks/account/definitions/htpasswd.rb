define :htpasswd_from_users, :owner => "root", :group => "root", :mode => "0440", :password_field => :password do
  if params[:query]
    query = params[:query]
  elsif params[:tags]
    tags = [params[:tags]].flatten
    query = Proc.new do |u|
      u[:tags] and (u[:tags] & tags).any?
    end
  elsif params[:users]
    users = [params[:users]].flatten
    query = Proc.new do |u|
      users.include?(u[:id])
    end
  else
    raise "no query or options specified"
  end

  content = node.run_state[:users].select(&query).select do |user|
    user[params[:password_field]]
  end.map do |user|
    "#{user[:id]}:#{user[params[:password_field]]}"
  end.join("\n")

  file params[:name] do
    content content
    owner params[:owner]
    group params[:group]
    mode params[:mode]
  end
end

define :htpasswd_from_databag, :owner => "root", :group => "root", :mode => "0440" do
  content = data_bag_item('htpasswd', params[:bag]).map do |user, password|
    user == "id" ? nil : "#{user}:#{password}"
  end.compact.sort.join("\n")

  file params[:name] do
    content content
    owner params[:owner]
    group params[:group]
    mode params[:mode]
  end
end
