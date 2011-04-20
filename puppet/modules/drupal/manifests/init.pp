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
    database => $project,
  }
  mysql::createuser { "create $project user": 
    user => $project, 
    password => $dbpassword,
    require => [
      Exec["create database: ${project}"],
    ]
  }
  mysql::grant { "grant all on $project database": 
    user => $project, 
    permission => "all", 
    entity => "${project}.*",
    require => [
      Exec["create user: ${project}"],
    ]
  }

  # install drupal
  drush::make{"make ${project}": 
    makefile => "${project}.make",
    destination => $docroot, 
    source_directory => $source_directory,
  }
  
  # install drupal
  drush::install{ "install drupal": 
    root => $docroot, profile => "buildkit", 
    dbuser => $project, dbpass => $dbpassword, dbname => $project,
    require => [
      Exec["create database: ${project}"],
      Exec["create user: ${project}"],
      Exec["grant ${project}, all, ${project}.*"],
      Exec["drush make ${project}.make"],
    ],
  }
  
  $source_directory = "/vagrant"   # stripcomponents($docroot,1)
  # Relocate the sites directory to the project directory and symlink to it
  file { "$source_directory/sites":
    ensure => "directory",
    source => "$docroot/sites",
    require => [
      Exec["drush install /vagrant/docroot"]
    ]
  }
  
  file { "$docroot/sites":
    ensure => "link",
    target => "../sites",
    force => "true",
    require => [ 
      File["$source_directory/sites"],
    ]
  }
  
  # Make the relationship between the web server and PHP explicit, since nginx needs
  # to restart after we establish the socket for communication between them
  Service["php5-fpm"] ~> Service["nginx"]
  
  # switch logging over to syslog
  drush::enable{"enable syslog logging": 
    module => 'syslog',
    url => $site_url, 
    root => $docroot,
    require => [
      Exec["drush install /vagrant/docroot"],
    ],
  }
  drush::disable{"disable database logging": 
    module => 'dblog', 
    url => $site_url,
    root => $docroot,
    require => [
      Exec["drush install /vagrant/docroot"],
    ],
  }
  
  # load a database extract, if it exists
  drush::loaddb{"load database extract: ${project}":
    url => $site_url,
    root => $docroot,
    file => "${source_directory}/db/${project}.sql",
    require => [
      Exec["drush install /vagrant/docroot"],
    ],
  }
  
}