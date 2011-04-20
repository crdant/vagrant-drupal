class maverick64 {
  
  # can I move these to my Vagrant file and reference them here?
  $host = "foundation.dev"
  $project = "foundation"
  $dbpassword = "ij2t%9hi3swi"
  $user1 = "admin"
  $user1password = "admin"
  $user1mail = "admin@mailinator.com"
  $source_directory = "/vagrant"
  $site_url = "http://${host}/"
  
  # setup the document root
  $docroot = "${source_directory}/docroot"
    
  package { "wget":
    ensure => "present",
  }
  
  # setup hosts for $host, m.$host, and www.$host to allow for mobile site
  # and having www.$host and $host map to the same site
  host { "$host":
    ensure => "present",
    ip     => "127.0.0.1",
    host_aliases => [ "www.$host", "m.$host"],
  }
  
  include nginx
  include php
  include mysql
  include drush
  include drupal

}

include maverick64
