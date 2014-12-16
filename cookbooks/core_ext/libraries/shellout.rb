require 'mixlib/shellout'

class ::Mixlib::ShellOut
  def set_user
    if user
      pwent = Etc.getpwnam(user)
      ENV["HOME"] = pwent.dir
      ENV["USER"] = ENV["USERNAME"] = user
      Process.uid = uid
      Process.euid = uid
    end
  end
end
