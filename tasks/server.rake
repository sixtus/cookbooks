namespace :server do

  desc "Bootstrap a Chef Server infrastructure"
  task :bootstrap do
    ENV['BATCH'] = 1
    Rake::Task["ssl:do_cert"].invoke(%x(hostname -f))
    sh(File.join(TOPDIR, "bootstrap/bootstrap.sh"))
  end

end
