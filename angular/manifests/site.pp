stage{'pre':}
stage{'post':}

Stage[pre] -> Stage[main] -> Stage[post]

node default {

  include common
  include ntp

  common::set_localtime{'set_localtime':
    zone => 'Europe/Madrid'
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

# flumen

  ## prefered system utilities
  package { ['aptitude', 'bash-completion', 'htop', 'tmate', 'net-tools', 'rsync', 'git-flow'] :
    ensure => present
  }

# flumen
}
