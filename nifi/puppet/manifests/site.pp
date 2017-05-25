stage{'pre':}
stage{'post':}

Stage[pre] -> Stage[main] -> Stage[post]

node default {

  include common

  common::set_localtime{'set_localtime':
    zone => 'Europe/Madrid'
  }

  $environment = hiera('environment')

  common::add_env{'APPLICATION_ENV':
    key   => 'APPLICATION_ENV',
    value => $environment,
  }

  include roles::nifi_server

  nifi_pg {'test':
    ensure => present
  }

  nifi_template {'IN.hmStaff.taskStatus.xml':
    path   => 'https://elrond.fluzo.com/IN.hmStaff.taskStatus.xml',
    ensure => present
  }
}
