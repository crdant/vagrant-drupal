class drush {

  $version = "7.x-4.4"
  $make_version = "6.x-2.1"
  
  ##
  # Create a directory for local commands and the supporting configuration directory
  # 
  $share_dir = "/usr/share"
  $local_share_dir = "/usr/local/share/drush"
  $command_dir = "${share_dir}/commands"

  ##
  # Install drush.  Tried using the maverick repository but it didn't work out, so I'm doing it direct
  #  
  file { $share_dir:
    alias   => "drush-share-directory",
    ensure  => "directory",
    mode    => 755,
    owner   => root,
    group   => root,
  }
  
  exec { "drush-download":
    command => "/usr/bin/wget -q -O - http://ftp.drupal.org/files/projects/drush-${version}.tar.gz | tar -xzf -",
    cwd => "$share_dir",
    creates => "${cwd}/${name}",
    require => [
      File["drush-share-directory"], 
    ],
  }
  
  file { "/usr/bin/drush":
    alias   => "drush-link",
    ensure  => "link",
    owner   => "root",
    group   => "root",
    target  => "$share_dir/drush/drush",
    require => [
      File["drush-share-directory"],
      Exec["drush-download"],
    ]
  }
  
  file { $local_share_dir:
    alias   => "drush-local-share-directory",
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
      File["drush-local-share-directory"], 
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
      Exec["drush-download"],
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
      Exec["drush-download"],
      File["drush-local-command-directory"], 
      Package["git"],
    ],
  }
  
  # add git so Drush make can use it
  package { "git":
    ensure => present,
  }

  ##
  # Install Drupal with an install profile
  # 
  define install($root, $dbuser, $dbpass, $dbname,
    $user1 = "admin", $user1password = "admin", $user1mail = "admin@example.com", 
    $profile = "standard") 
  {
    $base_requirements = [ File["drush-link"], Exec["drush-make-download"], ]
    
    if $require {
      $requirements = [ $base_requirements, $require ]
    } else {
      $requirements = $base_requirements
    }
    
  	exec { "drush install ${root}":
	    cwd => $root,
	    path => "/bin:/usr/bin",
	    command => "drush si --yes --verbose --account-name=$user1 --account-pass=$user1password --account-mail=$user1mail \
	      --db-url=mysqli://$dbuser:$dbpass@localhost/$dbname $profile ",
      require => [
        $requirements,
      ]
  	}
	}
    
  ##
  # Run drush make to set up the site before installing
  #
  define make($makefile, $destination, $source_directory) {
    $base_requirements = [ File["drush-link"], Exec["drush-make-download"], ]
  
    if $require {
      $requirements = [ $base_requirements, $require ]
    } else {
      $requirements = $base_requirements
    }
       
  	exec { "drush make ${makefile}":
	    cwd => $source_directory,
	    path => "/bin:/usr/bin",
	    command => "drush make $makefile $destination",
	    require => $requirements,
	    unless => "test -d $destination"
  	}
  }
  
  ##
  # Load the Drupal database from an export
  # 
  define loaddb($url,$root,$file) {

    # TODO: make agnostic to Drush versions, currently only 3.x
    # can't use the basic define for Drush commands here because I need to use the output of 
    # the call to the command as the command that I execute
    exec { "import db: $file":
	    cwd => $root,
	    path => "/bin:/usr/bin",
	    command => "drush --yes -l $url sql-connect < $file",
	    onlyif => "test -f $file",
      require => [
	      File["drush-link"],
	      Exec["drush-make-download"],
	    ],
  	}
  }
  
  ##
  # Enable a module
  #
  define enable($module, $url, $root) {
    drush::command { "enable $module" : 
      uid => 1, 
      command => "pm-enable", 
      arguments => $module,
      url => $url, 
      root => $root, 
    }
  }
  
  ##
  # Disable a module
  #
  define disable($module, $url, $root) {
    drush::command { "disable $module" : 
      uid => 1, 
      command => "dis", 
      arguments => $module,
      url => $url, 
      root => $root, 
    }
  }
  
  ##
  # run a Drush command as a specified user on the specified site
  #
  define command($uid,$command,$url,$root, $arguments = null) {
    $base_requirements = [ File["drush-link"], ]
  
    if $require {
      $requirements = [ $base_requirements, $require ]
    } else {
      $requirements = $base_requirements
    }
    
  	exec { "Drush command: $command $arguments":
	    cwd => $root,
	    path => "/bin:/usr/bin",
	    command => "drush --yes -u $uid -l $url ${command} ${arguments}",
      require => $requirements,	    
  	}
  }
}