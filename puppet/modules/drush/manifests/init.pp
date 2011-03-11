class drush {
  
  $make_version = "6.x-2.1"
  
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
  file { "/usr/share/drush/drushrc.php":
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
    command => "/usr/bin/wget -q -O - http://ftp.drupal.org/files/projects/drush_make-${make_version}.tar.gz | tar -xzf -",
    cwd => "$command_dir",
    creates => "${cwd}/${name}",
    require => [
      Package["drush"],
      File["drush-local-command-directory"], 
    ],
  }
  
  ##
  # Load the Drupal database from an export
  # 
  define loaddb($url,$root,$file) {
    # TODO: make agnostic to Drush versions, currently only 3.x
    # can't use the basic define for Drush commands here because I need to use the output of 
    # the call to the command as the command that I execute
    exec { "import db: $file":
	    require => Service["drush-link"],
	    cwd => $root,
	    path => "/bin:/usr/bin:/usr/local/bin",
	    command => "`drush -u $uid -l $url sql-connect` < $file"
  	}
  }
  
  ##
  # Update the Drupal database
  #
  define updatedb($url,$root) {
    drush::command { "updatedb" : user => 1, commmand => "updatedb", url => $url, root => $root }
  }
  
  
  ##
  # run a Drush command as a specified user on the specified site
  #
  define command($uid,$command,$url,$root, $arguments = null) {
  	exec { "Drush command: $command":
	    require => Service["drush-link"],
	    cwd => $root,
	    path => "/bin:/usr/bin:/usr/local/bin",
	    command => "drush -u $uid -l $url ${cmd} ${arguments}"
  	}
  }
}