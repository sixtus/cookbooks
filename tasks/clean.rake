namespace :clean do

  desc "Remove cookbooks"
  task :cookbooks, :pattern do |t, args|
    args.with_defaults(:pattern => ".*")
    knife :cookbook_bulk_delete, [args.pattern, '-y', '-p']
    knife :cookbook_upload, ['-a']
  end

  desc "Cleanup attributes"
  task :attributes do
    knife :exec, ["remove_envs.rb"]
    knife :exec, ["remove_munin_orphans.rb"]
    knife :exec, ["remove_splunk_orphans.rb"]
  end

end
