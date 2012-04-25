package "macvim" do
  action :upgrade
end

package "ctags"

ruby_block "copy .app to application" do
  block do
    installed_path = %x(brew --prefix macvim).chomp + "/MacVim.app"
    destination_path = "/Applications/MacVim.app"
    system("rsync -a --delete #{installed_path}/ #{destination_path}/")
  end
end
