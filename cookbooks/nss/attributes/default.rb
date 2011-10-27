default[:nss][:modules][:passwd] = %w(compat)
default[:nss][:modules][:shadow] = %w(compat)
default[:nss][:modules][:group] = %w(compat)

default[:nss][:modules][:hosts] = %w(files dns)
default[:nss][:modules][:networks] = %w(files dns)

default[:nss][:modules][:services] = %w(db files)
default[:nss][:modules][:protocols] = %w(db files)
default[:nss][:modules][:rpc] = %w(db files)
default[:nss][:modules][:ethers] = %w(db files)
default[:nss][:modules][:netmasks] = %w(files)
default[:nss][:modules][:netgroup] = %w(files)
default[:nss][:modules][:bootparams] = %w(files)

default[:nss][:modules][:automount] = %w(files)
default[:nss][:modules][:aliases] = %w(files)
