action :nothing do
end

action :create do
  cookbook_name = new_resource.cookbook
  cookbook = run_context.cookbook_collection[cookbook_name]

  override_dir = new_resource.instance.to_s
  filenames = cookbook.relative_filenames_in_preferred_directory(node, :templates, override_dir) rescue []

  if filenames.include?(new_resource.source)
    template_source = ::File.join(override_dir, new_resource.source)
  else
    template_source = new_resource.source
  end

  template new_resource.path do
    source template_source
    cookbook cookbook_name
    backup new_resource.backup if new_resource.backup
    group new_resource.group if new_resource.group
    local new_resource.local if new_resource.local
    mode new_resource.mode if new_resource.mode
    owner new_resource.owner if new_resource.owner
    path new_resource.path if new_resource.path
    variables new_resource.variables if new_resource.variables
  end
end
