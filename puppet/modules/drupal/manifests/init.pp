class drupal {
  
  file { "/etc/php5/fpm/php.ini":
    require => Package["php5-fpm"],
    owner => root,
    group => root,
    mode => 644,
    source => "puppet:///modules/drupal/php.ini"
  }
  
  define cron ( $docroot, $site_url) {
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
  mysql::grant { "grant all on $project DB": 
    user => $project, permission => "all", entity => "${project}.*" }

  # install drupal
  drush::make{"make site": 
    destination => $docroot, 
    source_directory => $source_directory,
  }
  
  $sites_directory = stripcomponents($docroot,1)
  # remove the sites directory and replace with a link to the sites directory in 
  # the project directory
  file { "$docroot/sites":
    target => $sites_directory,
    force => true,
  }
  
  # install drupal
  drush::install{ "install drupal": 
    root => $docroot, profile => "buildkit", 
    dbuser => $project, dbpass => $dbpassword, dbname => $project,
    require => [
      Exec["drush make site.make"],
      File["$docroot/sites"],
    ],
  }
  
  # Make the relationship between the web server and PHP explicit, since nginx needs
  # to restart after we establish the socket for communication between them
  Service["php5-fpm"] ~> Service["nginx"]
  
}