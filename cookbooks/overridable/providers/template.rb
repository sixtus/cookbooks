use_inline_resources

action :nothing do
end

action :create do
  nr = new_resource

  cookbook_name = nr.cookbook
  cookbook = run_context.cookbook_collection[cookbook_name]

  override_dir = nr.instance.to_s
  filenames = cookbook.relative_filenames_in_preferred_directory(node, :templates, override_dir) rescue []

  if filenames.include?(nr.source)
    template_source = ::File.join(override_dir, nr.source)
  else
    template_source = nr.source
    cookbook_name = nr.cookbook_name.to_s # oh my
  end

  template nr.path do
    source template_source
    cookbook cookbook_name
    backup nr.backup if nr.backup
    group nr.group if nr.group
    local nr.local if nr.local
    mode nr.mode if nr.mode
    owner nr.owner if nr.owner
    path nr.path if nr.path
    variables nr.variables if nr.variables
  end
end
