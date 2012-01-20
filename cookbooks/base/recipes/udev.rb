if node[:os] == "linux"
  # these links are missing in udev
  link "/dev/fd" do
    to "/proc/self/fd"
  end

  link "/dev/stdin" do
    to "/dev/fd/0"
  end

  link "/dev/stdout" do
    to "/dev/fd/1"
  end

  link "/dev/stderr" do
    to "/dev/fd/2"
  end
end
