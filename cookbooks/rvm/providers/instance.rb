include ChefUtils::RVM

action :create do
  rvm = infer_rvm_vars(new_resource.name, new_resource.version)

  template "#{rvm[:homedir]}/.gemrc" do
    source "gemrc"
    cookbook "rvm"
    owner rvm[:user]
    mode "0644"
    variables :rvm => rvm
  end

  bash_env = {
    'USER' => rvm[:user],
    'HOME' => rvm[:homedir],
    'TERM' => 'dumb'
  }

  bash "install-rvm-#{rvm[:user]}" do
    code <<-EOS
    export USER=#{rvm[:user]}
    export HOME=#{rvm[:homedir]}

    tmpfile=$(mktemp)
    curl -s -L -k https://get.rvm.io -o ${tmpfile}
    chmod +x ${tmpfile}
    ${tmpfile} --branch #{rvm[:version]} >/dev/null
    rm -f ${tmpfile}
    EOS

    not_if { ::File.read("#{rvm[:path]}/VERSION").split.first == rvm[:version] rescue false }
    user rvm[:user]
    group rvm[:group]
    environment(bash_env)
  end

  portage_preserve_libs "rvm-#{rvm[:user]}" do
    paths [
      "#{rvm[:path]}/rubies",
      "#{rvm[:path]}/gems",
    ]
  end
end

action :delete do
  rvm = infer_rvm_vars(new_resource.name)

  directory rvm[:path] do
    action :delete
    recursive true
  end
end

def initialize(*args)
  super
  @run_context.include_recipe "rvm"
end
