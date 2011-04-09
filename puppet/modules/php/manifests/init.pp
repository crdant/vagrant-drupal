class php {

  package { "php5-packages":
    name => ["php5-common", "php5-cli", "php5-mysql", "php-apc", "php5-gd", "php5-memcache"],
    ensure => present,
  }
  
  # FPM require libevent
  package { "libevent-1.4-2":
    alias => "libevent",
    ensure => present,
  }
  
  # Split FPM out from the other packages since it has a service and we depend on it for setting
  # up other elements of the installation.  This makes the dependencies clearer.
  
  # default configuration in the php5-fpm package leads to a post-processing failure if the
  # /var/www directory doesn't exist
  file { "/var/www": 
    ensure => directory,
    owner => root,
    group => root,
    mode => 755,
  }
  
  package { "php5-fpm":
    ensure => present,
    require => [
      Package["libevent"],
      File["/var/www"],
    ],
  }
  
  service { "php5-fpm":
    ensure => running,
    require => [
      Package["php5-fpm"],
      File["/etc/php5/fpm/conf.d/apc.ini"],
      File["/etc/php5/fpm/pool.d/${project}.conf"],
      File["/etc/php5/fpm/pool.d/www.conf"],
    ],
  }
  
  # remove the default pool configuration for our project-specific one
  file { "/etc/php5/fpm/pool.d/www.conf":
    ensure => absent,
  }
  
  # update the shared memory configuration for APC
  file { "/etc/php5/fpm/conf.d/apc.ini":
    require => Package["php5-fpm"],
    owner => root,
    group => root,
    mode => 644,
    source => "puppet:///modules/php/apc.ini"
  }
  
  # configure the FPM pool
  file { "/etc/php5/fpm/pool.d/${project}.conf":
    mode    => 644,
    owner   => root,
    group   => root,
    require => [ 
      Package["php5-fpm"], 
      File["/tmp/fpm"],
    ],
    notify => [
      Service["php5-fpm"],
    ],
    content  => template("php/site.conf.erb"),
  }
  
  # create the directory where the FPM socket will be located
  file { "/tmp/fpm":
    ensure  => directory,
    mode    => 700,
    owner   => www-data,
    group   => www-data,
  }
  
}