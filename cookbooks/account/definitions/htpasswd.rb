define :htpasswd_from_databag, :owner => "root", :group => "root", :mode => "0440" do
  content = node.run_state[:users].select(&params[:query]).select do |user|
    user[:password]
  end.map do |user|
    "#{user[:id]}:#{user[:password]}"
  end.join("\n")

  file params[:name] do
    content content
    owner params[:owner]
    group params[:group]
    mode params[:mode]
  end
end
