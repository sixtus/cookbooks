include ChefUtils::Account

use_inline_resources

action :create do
  nr = new_resource # rebind

  jvm_opts = [nr.jvm_opts].flatten.map do |opt|
    "-J#{opt}"
  end.join(' ')

  command = "ruby #{jvm_opts} #{nr.command}"

  deploy_rvm_wrapper nr.path do
    user nr.user
    command command
    cwd nr.cwd
    environment nr.environment
  end
end
