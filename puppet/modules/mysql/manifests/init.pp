class mysql {

  $root_password = "hiaph5bat8aw"
  
  package { "mysql-server":
    ensure => present,
  }
  
  service { "mysql":
    ensure => running,
    require => Package["mysql-server"],
  }
  
  mysql::setpassword{"set root password": user => "root", password => $root_password};
  
  # create a new database inside of mysql
  # this only creates the database if it does not exist.
  define createdb($database) {
    exec { "Create Database: $database":
      require => Service["mysql"],
      command => "mysql -u root --password=${root_password} -e 'create database if not exists $database'"
    }
  }
  
  # create a new user inside of mysql
  define createuser($user, $host = '%', $password) {
    exec { "Create User: $user":
      command => "mysql -u root --password=${root_password} -e 'create user \'${user}\'@\'${host}\' identified by \'${password}\');'",
      require => Service["mysql"],
    }
  }

  # set a user's password inside of mysql
  define setpassword($user, $host = '%', $password) {
    exec { "Create User: $user":
      command => "mysql -u root --password=${root_password} -e 'set password for \'${user}\'@\'${host}\' = password(\'${password}\');'",
      require => Service["mysql"],
    }
  }
}