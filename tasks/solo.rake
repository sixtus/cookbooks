require "highline/import"

namespace :solo do

  task :config do
    ENV['SOLO_USER'] = %x(whoami).chomp
    ENV['SOLO_FQDN'] = %x(hostname -f).chomp

    if ENV['SOLO_USER'] == "root"
      ENV['SOLO_CONFIG'] = File.join(TOPDIR, "config", "solo", "#{ENV['SOLO_FQDN']}.json")
      ENV['BATCH'] = "1"
      Rake::Task['ssl:do_cert'].invoke(ENV['SOLO_FQDN'])
    else
      ENV['SOLO_CONFIG'] = File.join(TOPDIR, "config", "solo", "#{ENV['SOLO_USER']}.json")
    end

    unless File.exist?(ENV['SOLO_CONFIG'])
      name = ask('Your name: ')
      email = ask('Your email address: ')
      github_user = ask('Your github username: ')

      b = binding()
      erb = Erubis::Eruby.new(File.read(File.join(TEMPLATES_DIR, 'solo.json')))

      File.open(ENV['SOLO_CONFIG'], "w") do |f|
        f.puts(erb.result(b))
      end
    end
  end

end

desc "Bootstrap local node with chef-solo"
task :solo => "solo:config" do
  sh("scripts/solo")
end

task :han do
  puts "May the force be with you!"
end
