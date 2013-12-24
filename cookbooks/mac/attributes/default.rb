default[:apple_id] = File.read("#{homedir}/.storerc").split.first rescue nil
default[:apple_password] = File.read("#{homedir}/.storerc").split.last rescue nil

default[:mac][:packages] = %w(
  ack
  apple-gcc42
  atool
  autoconf
  automake
  colordiff
  dos2unix
  findutils
  gawk
  gnu-sed
  gnu-tar
  icu4c
  libffi
  libksba
  libtool
  libxml2
  libxslt
  libyaml
  ncdu
  netcat
  nmap
  openssl
  pkg-config
  pwgen
  readline
  sqlite
  tree
  wget
)
