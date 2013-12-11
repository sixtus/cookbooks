include ChefUtils::Account

action :create do
  nr = new_resource # rebind
  user = get_user(nr.user)
  path = user[:dir]

  environment = nr.environment.map do |k, v|
    "export #{k}=#{v}"
  end.join("\n")

  content = <<-EOF
#!/bin/bash

export LANG=en_US.UTF-8
export HOME=#{path}
unset RUBYOPT

source #{path}/.rvm/scripts/rvm

export JAVAC="/etc/java-config-2/current-system-vm/bin/javac"
export JAVA_HOME="/etc/java-config-2/current-system-vm"
export JDK_HOME="/etc/java-config-2/current-system-vm"
#{environment}

cd #{nr.cwd}

exec #{nr.command} "$@"
EOF

  file nr.path do
    content content
    mode "755"
    owner user[:name]
    group user[:group][:name]
  end

end
