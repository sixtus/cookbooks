# base packages
if debian_based?
  node.set[:packages] = %w(
    ack
    acpitool
    apache2-utils
    atool
    autoconf
    automake
    build-essential
    bwm-ng
    colordiff
    dmidecode
    dnsutils
    dos2unix
    ethtool
    hdparm
    heirloom-mailx
    iotop
    iproute
    keychain
    less
    libxml2
    libxslt1.1
    libyaml-0-2
    lm-sensors
    lshw
    lsof
    mc
    mtr
    ncdu
    netcat
    nmap
    pciutils
    pwgen
    pydf
    realpath
    strace
    sysstat
    tcpdump
    tcptraceroute
    telnet
    traceroute
    tree
    whois
    xz-utils
  )
end

if debian?
  node.set[:packages] += %w(
    libffi5
  )
end

if ubuntu?
  node.set[:packages] += %w(
    libffi6
  )
end
