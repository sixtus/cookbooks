# base packages
if node[:platform] == "mac_os_x"
  node.set[:packages] = %w(
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
    keychain
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
end
