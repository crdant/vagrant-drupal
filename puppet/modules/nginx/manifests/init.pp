class nginx {
  package { "nginx":
    ensure => present,
  }

  service { "nginx":
    ensure => running,
    require => Package["nginx"],
  }

  file { "/etc/nginx":
    ensure => 'directory',
    mode    => 755,
    owner   => root,
    group   => root,
  }
  
  file { "/etc/nginx/sites-enabled":
    ensure => 'directory',
    mode    => 755,
    owner   => root,
    group   => root,
    require => [ File["/etc/nginx"] ],
  }
  
  # use the default location for maverick
  file { "/etc/nginx/sites-enabled/$host":
    mode    => 644,
    owner   => root,
    group   => root,
    require => [ Package["nginx"], File["/etc/nginx/sites-enabled"], ],
    content => template("nginx/project.erb"),
    notify  => [ Service ["nginx"], ],
  }
}