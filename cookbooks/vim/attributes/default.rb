default[:vim][:rcfile] = case node[:platform]
                         when "gentoo"
                           "/etc/vim/vimrc.local"
                         when "mac_os_x"
                           "#{node[:homedir]}/.vimrc"
                         end

default[:vim][:rcdir] = case node[:platform]
                        when "gentoo"
                          "/etc/vim"
                        when "mac_os_x"
                          "#{node[:homedir]}/.vim"
                        end

default[:vim][:plugins] = {
  :auto_mkdir => "https://github.com/DataWraith/auto_mkdir",
  :coffee_script => "https://github.com/kchmck/vim-coffee-script",
  :endwise => "https://github.com/tpope/vim-endwise",
  :haml => "https://github.com/tpope/vim-haml",
  :javascript => "https://github.com/pangloss/vim-javascript",
  :markdown => "https://github.com/tpope/vim-markdown",
  :matchit => "https://github.com/vim-scripts/matchit.zip",
  :ruby => "https://github.com/vim-ruby/vim-ruby",
}
