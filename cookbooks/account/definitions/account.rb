define :account,
       :uid => nil,
       :gid => "users",
       :groups => [],
       :shell => "/bin/bash",
       :comment => nil,
       :password => "!",
       :home => nil,
       :home_mode => "0750",
       :home_owner => nil,
       :home_group => nil,
       :authorized_keys => nil,
       :authorized_keys_for => nil,
       :key_source => nil,
       :action => :create do
  include_recipe "account"

  home = params[:home]
  home ||= "/home/#{params[:name]}"

  home_owner = params[:home_owner]
  home_group = params[:home_group]

  key_source = params[:key_source]

  group "#{params[:gid]}-#{rrand}" do
    group_name params[:gid]
    append true
  end

  user "#{params[:name]}-#{rrand}" do
    username params[:name]
    uid params[:uid]
    gid params[:gid]
    shell params[:shell]
    comment params[:comment]
    password params[:password]
    home home
    action params[:action]
  end

  if params[:action] == :create
    params[:groups].each do |g|
      group "#{g}-#{rrand}" do
        group_name g
        members params[:name]
        append true
      end
    end

    home_owner ||= params[:name]
    home_group ||= params[:gid]
  else
    home_owner ||= "root"
    home_group ||= "root"
  end

  directory "/home-#{rrand}" do
    path File.dirname(home)
    owner "root"
    group "root"
    mode "0755"
    recursive true
    not_if { File.directory?(File.dirname(home)) }
  end

  directory "#{home}-#{rrand}" do
    path home
    owner home_owner
    group home_group
    mode params[:home_mode]
  end

  directory "#{home}/.ssh-#{rrand}" do
    path "#{home}/.ssh"
    owner home_owner
    group home_group
    mode "0700"
  end

  if key_source
    cookbook_file "#{home}/.ssh/id_rsa-#{rrand}" do
      path "#{home}/.ssh/id_rsa"
      source key_source
      owner home_owner
      group home_group
      mode "0600"
    end

    cookbook_file "#{home}/.ssh/id_rsa.pub-#{rrand}" do
      path "#{home}/.ssh/id_rsa.pub"
      source "#{key_source}.pub"
      owner home_owner
      group home_group
      mode "0644"
    end
  end

  # don't create an authorized keys file if authorized_keys is nil.
  # if it's empty -- i.e. [] -- then we would create an empty
  # authorized keys but with nil, the file is not created.
  if !params[:authorized_keys].nil? or !params[:authorized_keys_for].nil?
    authorized_keys = authorized_keys_for([params[:authorized_keys_for]].flatten.compact)
    authorized_keys += [params[:authorized_keys]].flatten.compact

    file "#{home}/.ssh/authorized_keys-#{rrand}" do
      path "#{home}/.ssh/authorized_keys"
      content(authorized_keys.sort.uniq.join("\n") + "\n")
      owner home_owner
      group home_group
      mode "0600"
    end
  end
end

define :account_from_databag do
  user = node.run_state[:users].select do |u|
           u[:id] == params[:name]
         end.first

  # bind params to a local variables, otherwise the scope in the
  # account block below will have empty params
  p = params

  account user[:id] do
    [user.keys + p.keys].flatten.each do |k|
      next if [:id, :name].include?(k.to_sym)
      v = user[k]
      v ||= p[k]
      send k.to_sym, v if v
    end
  end
end

define :accounts_from_databag,
  :groups => [] do

  node.run_state[:users].select(&params[:query]).each do |user|
    account_from_databag user[:id]

    params[:groups].each do |g|
      group "#{g}-#{rrand}" do
        group_name g
        members user[:id]
        append true
      end
    end
  end
end
