class php {

  package { "php5-packages":
    name => ["php5-common", "php5-cli", "php5-mysql", "php5-fpm", "php5-apc", "php5-gd"],
    ensure => present,
  }
  
}