stage{'pre':}
stage{'post':}

Stage[pre] -> Stage[main] -> Stage[post]

node default {

  include ntp
  include nodejs

  package { 'imagemagick':
    ensure  => present
  }

  common::set_localtime{'set_localtime':
    zone => 'Europe/Madrid'
  }

  common::add_env{'RAILS_ENV':
    key   => 'RAILS_ENV',
    value => 'development',
  }

  common::add_env{'RACK_ENV':
    key   => 'RAILS_ENV',
    value => 'development',
  }

  exec { 'installing_heroku_tools':
    command  => 'wget -O- https://toolbelt.heroku.com/install-ubuntu.sh | sh',
    user     => 'root',
    unless   => '/usr/bin/dpkg -l heroku-toolbelt | grep ii',
    provider => shell
  }

  class {'roles::memcached_server':
    memory          => '256',
    max_object_size => '3m'
  }

  $backup_dir = lookup('backup_dir')

  file {'backup_dir':
    ensure => directory,
    path   => $backup_dir,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }
/*
  class {'::mongodb::globals':
    version             => '3.2.7',
    manage_package_repo => true,
    bind_ip             => '0.0.0.0'
  }->
  class {'::mongodb::client': }->
  class {'::mongodb::server':
    verbose       => true,
    require       => Class['mongodb::globals']
  }

  package { 'mongodb-org-tools':
    ensure  => present,
    require => Class['mongodb::server']
  }
*/

  include roles::postgresql_server

  postgresql::server::db { 'ror':
    user     => 'ror',
    password => 'ror',
  }


# hmobile


  ## install mysql with root password 'root'

  $ruby_packages = ['ruby', 'ruby-dev', 'build-essential', 'libsqlite3-dev', 'zlib1g-dev']

  package {$ruby_packages:
    ensure => present
  }

  class {'mysql::server':
    root_pass  => 'root',
    backup_dir => '/srv/backup',
    s3_backup  => false,
    require    => File['backup_dir']
  }

  ## make available specific version of rbenv used in staff-rails project
  rbenv::plugin { [ 'rbenv/rbenv-vars', 'rbenv/ruby-build' ]: }
  rbenv::build { '2.4.2': global => true }

  ## to share terminal
  package { 'tmate':
    ensure => present
  }

  ## to be able to run rails 5.2 system tests
  package { ['firefox-geckodriver', :
    ensure => present
  }

  ## requirement of gem mini_magick
  ## already required by global site.pp
  # package { 'imagemagick':
  #   ensure  => present
  # }

# hmobile
}
