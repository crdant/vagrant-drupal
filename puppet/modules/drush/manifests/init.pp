class drush {

  package { "drush":
    ensure => present,
  }
  
  ##
  # Create a directory for local commands and the supporting configuration directory
  # 
  $share_dir = "/usr/local/share/drush"
  $command_dir = "${share_dir}/commands"
  
  file { $share_dir:
    alias   => "drush-share-directory",
    ensure  => "directory",
    mode    => 755,
    owner   => root,
    group   => root,
  }
  
  file { $command_dir:
    alias   => "drush-local-command-directory",
    ensure  => "directory",
    mode    => 755,
    owner   => root,
    group   => root,
    require => [
      File["drush-share-directory"], 
    ],
  }
  
  ##
  # Setup the drushrc for the local commands
  #
  file { "/opt/drush/drushrc.php":
    alias   => "drush-drushrc",
    mode    => "755",
    owner   => "root",
    group   => "root",
    require => [ 
      File["drush-local-command-directory"], 
    ],
    content  => template("drush/drushrc.php.erb"),
  }
  
  ##
  # Install drush make to the local commands directory
  #
  exec { "drush-make-download":
    command => "/usr/bin/wget -q ",
    cwd => '$command_dir',
    creates => "${cwd}/${name}",
    require => [
      Package["drush"],
      File["drush-local-command-directory"], 
    ],
  }
}