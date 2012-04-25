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
  :closetag => "https://github.com/vim-scripts/closetag.vim",
  :coffee_script => "https://github.com/kchmck/vim-coffee-script",
  :endwise => "https://github.com/tpope/vim-endwise",
  :haml => "https://github.com/tpope/vim-haml",
  :javascript => "https://github.com/pangloss/vim-javascript",
  :matchit => "https://github.com/vim-scripts/matchit.zip",
  :ruby => "https://github.com/vim-ruby/vim-ruby",
  :ctrlp => "https://github.com/kien/ctrlp.vim.git",
  :"vim-rails" => "https://github.com/tpope/vim-rails.git",
}
