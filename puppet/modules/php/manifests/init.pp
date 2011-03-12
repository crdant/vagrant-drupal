class php {

  package { "php5-packages":
    name => ["php5-common", "php5-cli", "php5-mysql", "php-apc", "php5-gd", "php5-memcache"],
    ensure => present,
  }
  
  # Split FPM out from the other packages since it has a service and we depend on it for setting
  # up other elements of the installation.  This makes the dependencies clearer.
  package { "php5-fpm":
    ensure => present,
  }
  
  service { "php5-fpm":
    ensure => running,
    require => Package["php5-fpm"],
  }
  
  # update the shared memory configuration for APC
  file { "/etc/php5/fpm/conf.d/apc.ini":
    require => Package["php5-fpm"],
    owner => root,
    group => root,
    mode => 644,
    source => "puppet:///php/apc.ini"
  }
  
}