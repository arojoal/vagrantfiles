stage{'pre':}
stage{'post':}

Stage[pre] -> Stage[main] -> Stage[post]

node default {

  include common
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


  # do not let heroku script to install ruby. It can get stuck during interactive install
  package { 'ruby' :
    ensure => present
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

  ## prefered system utilities
  package { ['aptitude', 'bash-completion', 'htop', 'tmate', 'net-tools', 'rsync', 'git-flow'] :
    ensure => present
  }

  ## install mysql with root password 'root'

  $ruby_packages = ['ruby-dev', 'build-essential', 'libsqlite3-dev', 'zlib1g-dev']

  package {$ruby_packages:
    ensure => present
  }

  class {'mysql::server':
    root_pass  => 'root',
    backup_dir => '/srv/backup',
    s3_backup  => false,
    require    => File['backup_dir']
  }

  ## to be able to run rails 5.2 system tests
  package { 'firefox-geckodriver' :
    ensure => present
  }

  ## requirement of gem mini_magick
  ## already required by global site.pp
  # package { 'imagemagick':
  #   ensure  => present
  # }

  ## create database for staff-rails
  mysql::db {['hmobile_oportunities_development', 'hmobile_oportunities_test']:
    collation_name => 'utf8_general_ci'
  }

  ## make available specific version of rbenv used in staff-rails project
  class { 'rbenv': }
  rbenv::plugin { [ 'rbenv/ruby-build' ]: }
  rbenv::build { '2.7.7': global => true }
  rbenv::build { '2.6.5': global => true }
  rbenv::build { '2.4.6': global => true }
  rbenv::gem { 'bundler_for_27': gem => 'bundler', version => '1.17.3', ruby_version  => '2.7.7' }
  rbenv::gem { 'bundler_for_26': gem => 'bundler', version => '1.17.3', ruby_version  => '2.6.5' }
  rbenv::gem { 'bundler_for_24': gem => 'bundler', version => '1.17.3', ruby_version  => '2.4.6' }

  # allow compilation of curb 0.9.6 with native extensions
  package { 'libcurl4-openssl-dev' :
    ensure => present
  }

  # allow compilation of pg 1.0.0 with native extensions
  package { 'libpq-dev' :
    ensure => present
  }

  #install yarn
  class { 'yarn': }

# hmobile
}
