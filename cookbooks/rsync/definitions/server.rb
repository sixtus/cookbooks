define :rsync_module do
  node.default[:rsync][:modules][params.delete(:name)] = params
  include_recipe "rsync::server"
end
