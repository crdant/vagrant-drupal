class drupal {
  
  file { "/etc/php5/fpm/php.ini":
    require => Package["php5-fpm"],
    owner => root,
    group => root,
    mode => 644,
    source => "puppet:///drupal/php.ini"
  }
  
  define cron ($site_url, $site_group, $site_name) {
    cron { "${site_name}-cron":
      command => "/opt/drush/drush -u 1 -r $docroot -l $site_url cron",
      user => root,
      minute => '*/10',
      require => [
        File["drush"],
      ],
    }
  }
  
  # set up the database for the site
  mysql::createdb{ "create $project DB": 
    database => $project }
  mysql::createuser { "create $project DB": 
    user => $project, password => $dbpassword }

  # install drupal
  drush::make{"make site": destination => $docroot, source_directory => $source_directory }
  drush::install{"install drupal":
    dbuser => $project, dbpass => $dbpassword, dbname => $project, profile => "buildkit"
  }
  
}