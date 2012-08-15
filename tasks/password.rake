require "highline/import"

desc "Generate a crypt(3) compatible password"
task :password do
  p1 = ask('Password: ') do |q|
    q.echo = false
  end

  p2 = ask('Confirm: ') do |q|
    q.echo = false
    q.validate = /^#{p1}$/
  end

  STDOUT.puts

  raise "passwords do not match" unless p1 == p2

  salt = SecureRandom.hex(8)
  STDOUT.puts p1.crypt("$1$#{salt}$")
  salt = SecureRandom.hex(4)
  STDOUT.puts p1.crypt("$6$#{salt}$")
end
