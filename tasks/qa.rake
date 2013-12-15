desc "Run QA tools for given cookbook"
task :qa, :cookbook do |t, args|
  if File.directory?("cookbooks/#{args.cookbook}")
    path = "cookbooks/#{args.cookbook}"
  elsif File.directory?("site-cookbooks/#{args.cookbook}")
    path = "site-cookbooks/#{args.cookbook}"
  else
    raise "cookbook not found"
  end
  sh("tailor #{path} || :")
  sh("foodcritic -t ~FC011 -t ~FC045 #{path} || :")
end
