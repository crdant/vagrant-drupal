class php {

  package { "php5-packages":
    name => ["php5-common", "php5-cli", "php5-mysql", "php5-fpm", "php-apc", "php5-gd"],
    ensure => present,
  }
  
  file { "/etc/php5/php-fpm/apc.ini":
    require => Package["php5-fpm"],
    owner => root,
    group => root,
    mode => 644,
    source => "puppet:///php/apc.ini"
  }
  
}