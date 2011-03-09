class lucid32 {
  
  $host = "openatrium.dev"
  $project = "openatrium"
  
  package { "wget":
    ensure => "present"
  }
  
  # link the document root into the vagrant project directory
  # ln -s /vagrant/drupal/docroot /var/www/docroot
  file {"/var/www/docroot":
    target => "/vagrant/docroot"
  }
  
  include nginx
  include php
  # include mysql
  # include drush
  # include drupal
  # include user
  
  # install open atrium with drush make
  # http://drupalcode.org/project/openatrium.git/blob/HEAD:/openatrium.make

}

include lucid32