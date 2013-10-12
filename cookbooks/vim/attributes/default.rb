include_attribute "base"

default[:vim][:rcfile] = if mac_os_x?
                           "#{node[:homedir]}/.vimrc"
                         else
                           root? ? "/etc/vim/vimrc.local" : "#{node[:homedir]}/.vimrc"
                         end

default[:vim][:rcdir] = if mac_os_x?
                          "#{node[:homedir]}/.vim"
                        else
                          root? ? "/etc/vim" : "#{node[:homedir]}/.vim"
                        end

default[:vim][:plugins] = {
  :auto_mkdir => "https://github.com/DataWraith/auto_mkdir",
  :coffee_script => "https://github.com/kchmck/vim-coffee-script",
  :endwise => "https://github.com/tpope/vim-endwise",
  :git => "https://github.com/tpope/vim-git",
  :haml => "https://github.com/tpope/vim-haml",
  :javascript => "https://github.com/pangloss/vim-javascript",
  :markdown => "https://github.com/tpope/vim-markdown",
  :matchit => "https://github.com/vim-scripts/matchit.zip",
  :powerline => "https://github.com/skwp/vim-powerline",
  :ruby => "https://github.com/vim-ruby/vim-ruby",
  :solarized => "https://github.com/hollow/vim-colors-solarized",
}
