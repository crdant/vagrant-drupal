class mysql {
  package { "mysql-server":
    ensure => present,
  }
  
  service { "mysql-server":
    ensure => running,
    require => Package["mysql-server"],
  }
}