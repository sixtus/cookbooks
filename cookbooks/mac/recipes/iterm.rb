if platform?("mac_os_x")
  mac_package "iTerm" do
    source "http://www.iterm2.com/downloads/stable/iTerm2_v1_0_0.zip"
    type "zip_app"
  end

  execute "fc-cache-menlo-powerline" do
    command "/opt/X11/bin/fc-cache"
    action :nothing
  end

  remote_file "#{node[:homedir]}/Library/Fonts/Menlo-Powerline.otf" do
    source "https://gist.github.com/raw/1595572/417a3fa36e35ca91d6d23ac961071094c26e5fad/Menlo-Powerline.otf"
    notifies :run, "execute[fc-cache-menlo-powerline]"
  end

  mac_userdefaults "hide tab bar when there is only one tab" do
    domain "com.googlecode.iterm2"
    key "HideTab"
    value "1"
  end

  mac_userdefaults "hide border around window" do
    domain "com.googlecode.iterm2"
    key "UseBorder"
    value "0"
  end
end
