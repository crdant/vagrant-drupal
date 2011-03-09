class nginx {
  package { "nginx":
    ensure => present,
  }

  service { "nginx":
    ensure => running,
    require => Package["nginx"],
  }
  
  # use the default location for lucid
  file { "/etc/nginx/sites-enabled/$host":
    mode    => 644,
    owner   => root,
    group   => root,
    require => Package["nginx"],
    content  => template("nginx/project.erb"),
  }
}