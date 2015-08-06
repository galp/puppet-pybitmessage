class pybitmessage(
  $user              = 'bitmessage',
  $daemon            = true,
  $proj_name         = 'bitmessage',
  $repo = 'https://github.com/Bitmessage/PyBitmessage',

)
{
  $dir  = "/home/${user}/pybitmessage"
  $command           = "python2.7 ${dir}/src/bitmessagemain.py"
  $packages = ['python2.7','git']

  package { $packages:
    ensure => installed,
    require => Class['apt'],
  }

  user { $user:
    ensure     => present,
    managehome => true,
    shell      => '/bin/bash',
  }

  vcsrepo { $dir:
    ensure   => present,
    provider => git,
    source   => $repo,
    require  => User[$user],
  }
  service { $proj_name :
    ensure  => running,
    enable  => true,
    require => [File["/etc/init.d/${proj_name}"],Vcsrepo[$dir]],
  }

  $required_dirs = ["/home/${user}/.config/","/home/${user}/.config/PyBitmessage"] #fix
  file  { $required_dirs:
    ensure  => directory,
    recurse => true,
    owner   => $user,
    group   => $user
  }
  
  file  {"/home/${user}/.config/PyBitmessage/keys.dat":
    ensure  => present,
    content => template("${module_name}/keys_dat.erb"),
    owner   => $user,
    group   => $user,
    require => File["/home/${user}/.config/PyBitmessage/"],
  }
  file  {"/etc/init.d/${proj_name}":
    ensure  => present,
    content => template("${module_name}/bitmessage_start_sh.erb"),
    notify => Service[$proj_name],
  }

  file_line { "${proj_name}_daemon":
    ensure   => present,
    line     => "daemon = true",
    path     => "/home/${user}/.config/PyBitmessage/keys.dat",
    require  => File["/home/${user}/.config/PyBitmessage/keys.dat"],
  }
}

  
