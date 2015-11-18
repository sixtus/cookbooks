if gentoo?
  package "dev-db/postgresql"
  package "dev-ruby/pg"
elsif mac_os_x?
  homebrew_package "postgresql"
end
