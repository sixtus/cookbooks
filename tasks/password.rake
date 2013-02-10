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

  puts

  raise "passwords do not match" unless p1 == p2

  if p1.length == 0
    p1 = %x(pwgen -s 10 1).chomp
    puts "You did not enter a password, generating one for you:"
    puts
    puts "    #{p1}"
    puts
  end

  salt = SecureRandom.hex(8)
  printf "password1 '%s'\n", p1.crypt("$1$#{salt}$")
  salt = SecureRandom.hex(4)
  printf "password '%s'\n", p1.crypt("$6$#{salt}$")
end
