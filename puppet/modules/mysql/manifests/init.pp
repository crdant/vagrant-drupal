class mysql {

  $root_password = "hiaph5bat8aw"
  
  package { "mysql-server":
    ensure => present,
  }
  
  service { "mysql":
    ensure => running,
    require => Package["mysql-server"],
  }
  
  # set the MySQL root password
  exec { "set root password": 
    command => "mysqladmin -u root password ${mysql::root_password}",
    unless => "mysql -u root --password=${mysql::root_password} -e 'select 1 + 1;'",
    path => "/bin:/usr/bin",
    require => [
      Package["mysql-server"], 
      Service["mysql"],
    ],
  }
  
  # create a new database inside of mysql
  # this only creates the database if it does not exist.
  define createdb($database) {
    exec { "Create Database: $database":
      path => "/bin:/usr/bin",
      command => "mysql -u root --password=${mysql::root_password} -e 'create database if not exists $database;'",
      require => [
        Service["mysql"],
        Exec["set root password"],
      ],
    }
  }
  
  # create a new user inside of mysql
  define createuser($user, $host = '%', $password) {
    exec { "Create User: $user":
      command => "mysql -u root --password=${mysql::root_password} -e \"create user \'${user}\'@\'${host}\' identified by \'${password}\';\"",
	    path => "/bin:/usr/bin",
	    require => [
	      Service["mysql"],
        Exec["set root password"],
      ]
    }
  }

  # grant rights to a user
  define grant($user, $host = '%', $permission, $entity) {
    exec { "Grant: $user, $permission, $entity":
      command => "mysql -u root --password=${mysql::root_password} -e \"grant ${permission} on ${entity} to \'${user}\'@\'${host}\';\"",
	    path => "/bin:/usr/bin",
	    require => [
	      Service["mysql"],
        Exec["set root password"],
      ]
    }
  }
}