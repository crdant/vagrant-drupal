class maverick64 {
  
  # can I move these to my Vagrant file and reference them here?
  $host = "openatrium.dev"
  $project = "openatrium"
  # this is already defined in the vagrant config, can I grab it?
  $ip = "172.31.33.101"
  
  # setup the document root
  $docroot = "/vagrant/docroot"
  
  package { "wget":
    ensure => "present",
  }
  
  # setup hosts for $host, m.$host, and www.$host to allow for mobile site
  # and having www.$host and $host map to the same site
  host { "$host":
    ensure => "present",
    ip     => "$ip",
    host_aliases => [ "www.$host", "m.$host"],
  }
  
  include nginx
  include php
  include mysql
  include drush
  include drupal::development
  # include user
  
  # install open atrium with drush make
  # http://drupalcode.org/project/openatrium.git/blob/HEAD:/openatrium.make
}

include maverick64