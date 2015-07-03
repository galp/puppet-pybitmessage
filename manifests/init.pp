class pybitmessage(
  $user              = 'bitmessage',
  $daemon            = true,
  $proj_name         = 'pybitmessage',
  $pybitmessage_repo = 'https://github.com/Bitmessage/PyBitmessage',
)
{
  $pybitmessage_dir  = "/home/${user}/pybitmessage"
  $packages = ['python2.7','git']

  package { $packages:
    ensure => installed,
  }

  user { $user:
    ensure     => present,
    managehome => true,
    shell      => '/bin/bash',
  }

  vcsrepo { $pybitmessage_dir:
    ensure   => present,
    provider => git,
    source   => $pybitmessage_repo,
    require  => User[$user],
  }
  # service { $proj_name :
  #   ensure  => running,
  #   enable  => true,
  #   require => [File["/etc/systemd/system/${proj_name}.service"],Vcsrepo[$pybitmessage_dir]],
  # }
  # file {"/etc/systemd/system/${proj_name}.service" :
  #   ensure  => present,
  #   content => template("${module_name}/${proj_name}_service.erb"),
  #   notify  => Service[ $proj_name ],
  #   require => Vcsrepo[$pybitmessage_dir],
  # }
  file_line { "${proj_name}_start":
    ensure   => present,
    line     => "su -c 'python ${$pybitmessage_dir}/src/bitmessagemain.py > ~/bitmessage.log' ${user}",
    path     => '/etc/rc.local',
    require  => Vcsrepo[$pybitmessage_dir],
  }
  file_line { "${proj_name}_remove_exit":
    ensure   => absent,
    line     => 'exit 0',
    path     => '/etc/rc.local',
  }

  file  {"/home/${user}/.config/PyBitmessage/keys.dat":
    ensure  => present,
    recurse => true,
    owner   => $user,
    group   => $user
  }
  file_line { "${proj_name}_daemon":
    ensure   => present,
    line     => "daemon = $daemon",
    path     => "/home/${user}/.config/PyBitmessage/keys.dat",
    require  => File["/home/${user}/.config/PyBitmessage/keys.dat"],
  }
}

  
