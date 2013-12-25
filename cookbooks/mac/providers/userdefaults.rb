require 'chef/mixin/shell_out'
require 'chef/mixin/language'
include Chef::Mixin::ShellOut

use_inline_resources

action :write do
  unless @userdefaults.is_set
    cmd = "defaults write #{new_resource.domain} "
    cmd << "'#{new_resource.key}' " if new_resource.key

    type = new_resource.type
    value = "'#{new_resource.value}'"

    case new_resource.value
    when TrueClass, FalseClass
      type ||= 'boolean'
    when Integer
      type ||= 'integer'
    when Float
      type ||= 'float'
    when Hash
      type ||= 'dict'

      # creates a string of Key1 Value1 Key2 Value2...
      value = new_resource.value.map { |k, v| "\"#{k}\" \"#{v}\"" }.join(' ')
    end

    cmd << "-#{type} " if type
    cmd << value
    execute cmd
  end
end

def load_current_resource
  @userdefaults = Chef::Resource::MacUserdefaults.new(new_resource.name)
  @userdefaults.key(new_resource.key)
  @userdefaults.domain(new_resource.domain)
  @userdefaults.is_set(is_set)
end

def is_set
  tpcmd = "defaults read-type #{new_resource.domain} "
  tpcmd << "'#{new_resource.key}' " if new_resource.key
  v = shell_out("#{tpcmd} | awk '{print $3}'")

  return false if v.stdout.empty?

  case v.stdout.split.first.chomp
  when 'boolean'
    pattern = new_resource.value ? "1" : "0"
  else
    pattern = new_resource.value.to_s
  end

  drcmd = "defaults read #{new_resource.domain} "
  drcmd << "'#{new_resource.key}' " if new_resource.key
  v = shell_out("#{drcmd} | grep -qx '#{pattern}'")

  v.exitstatus == 0
end
