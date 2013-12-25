desc "Run QA tools for given cookbook"
task :qa, :cookbook do |t, args|
  if args.cookbook.nil? || args.cookbook.empty?
    path = "."
  elsif File.directory?("cookbooks/#{args.cookbook}")
    path = "cookbooks/#{args.cookbook}"
  elsif File.directory?("site-cookbooks/#{args.cookbook}")
    path = "site-cookbooks/#{args.cookbook}"
  end
  files = Dir["#{path}/**/*.rb"].reject do |path|
    path =~ /\/(files|templates)\//
  end
  sh("tailor #{files.join(" ")} || :")
  sh("foodcritic -t ~FC011 -t ~FC045 #{path} || :")
end
