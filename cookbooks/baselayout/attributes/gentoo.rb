if gentoo?
  default[:baselayout][:groups] = {
    :root => {
      :gid => 0,
      :members => "root",
    },
    :bin => {
      :gid => 1,
      :members => "root,bin,daemon",
    },
    :daemon => {
      :gid => 2,
      :members => "root,bin,daemon",
    },
    :sys => {
      :gid => 3,
      :members => "root,bin,adm",
    },
    :adm => {
      :gid => 4,
      :members => "root,adm,daemon",
      :append => true,
    },
    :tty => {
      :gid => 5,
      :members => "",
    },
    :disk => {
      :gid => 6,
      :members => "root,adm",
    },
    :lp => {
      :gid => 7,
      :members => "lp",
    },
    :mem => {
      :gid => 8,
      :members => "",
    },
    :kmem => {
      :gid => 9,
      :members => "",
    },
    :wheel => {
      :gid => 10,
      :members => "root",
      :append => true,
    },
    :floppy => {
      :gid => 11,
      :members => "root",
    },
    :mail => {
      :gid => 12,
      :members => "",
      :append => true,
    },
    :news => {
      :gid => 13,
      :members => "news",
    },
    :uucp => {
      :gid => 14,
      :members => "uucp",
    },
    :console => {
      :gid => 17,
      :members => "",
    },
    :audio => {
      :gid => 18,
      :members => "",
    },
    :cdrom => {
      :gid => 19,
      :members => "",
    },
    :tape => {
      :gid => 26,
      :members => "root",
    },
    :video => {
      :gid => 27,
      :members => "root",
    },
    :cdrw => {
      :gid => 80,
      :members => "",
    },
    :usb => {
      :gid => 85,
      :members => "",
    },
    :users => {
      :gid => 100,
      :members => "",
      :append => true,
    },
    :utmp => {
      :gid => 406,
      :members => "",
    },
    :nogroup => {
      :gid => 65533,
      :members => "",
    },
    :nobody => {
      :gid => 65534,
      :members => "",
    },
    :man => {
      :gid => 15,
      :members => "",
    },
  }

  default[:baselayout][:users] = {
    :bin => {
      :uid => 1,
      :gid => 1,
      :home => "/bin",
      :shell => "/bin/false",
    },
    :daemon => {
      :uid => 2,
      :gid => 2,
      :home => "/sbin",
      :shell => "/bin/false",
    },
    :adm => {
      :uid => 3,
      :gid => 4,
      :home => "/var/adm",
      :shell => "/bin/false",
    },
    :lp => {
      :uid => 4,
      :gid => 7,
      :home => "/var/spool/lpd",
      :shell => "/bin/false",
    },
    :sync => {
      :uid => 5,
      :gid => 0,
      :home => "/sbin",
      :shell => "/bin/sync",
    },
    :shutdown => {
      :uid => 6,
      :gid => 0,
      :home => "/sbin",
      :shell => "/sbin/shutdown",
    },
    :halt => {
      :uid => 7,
      :gid => 0,
      :home => "/sbin",
      :shell => "/sbin/halt",
    },
    :mail => {
      :uid => 8,
      :gid => 12,
      :home => "/var/spool/mail",
      :shell => "/sbin/nologin",
    },
    :news => {
      :uid => 9,
      :gid => 13,
      :home => "/var/spool/news",
      :shell => "/bin/false",
    },
    :uucp => {
      :uid => 10,
      :gid => 14,
      :home => "/var/spool/uucp",
      :shell => "/bin/false",
    },
    :operator => {
      :uid => 11,
      :gid => 0,
      :home => "/root",
      :shell => "/bin/bash",
    },
    :nobody => {
      :uid => 65534,
      :gid => 65534,
      :home => "/var/empty",
      :shell => "/bin/false",
    },
    :man => {
      :uid => 13,
      :gid => 15,
      :home => "/usr/share/man",
      :shell => "/sbin/nologin",
      :comment => "added by portage for man",
    },
  }
end
