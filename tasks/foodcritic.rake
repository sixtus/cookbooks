require 'foodcritic'

task :lint do
  cmd_line = FoodCritic::CommandLine.new(["cookbooks", "site-cookbooks"])
  review, status = FoodCritic::Linter.check(cmd_line)
  warnings =  review.warnings.reject do |w|
    w.rule.code == 'FC001' or
    (w.rule.code == 'FC003' and w.match[:filename] == 'cookbooks/base/recipes/default.rb')
  end.map do |w|
    "#{w.rule.code}: #{w.rule.name}: #{w.match[:filename]}"
  end.sort.uniq

  puts warnings.join("\n")
end
