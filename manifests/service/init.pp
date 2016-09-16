# == Define: graphdb::service::init
#
# Installs init.d configuration and defines service with init provider
#
# === Parameters
#
# [*ensure*]
#
#   Whether the service should exist. Possible values are present and absent.
#
# [*service_ensure*]
#
#   Whether a service should be running. Possible values are running, stopped, true and false.
#
# [*service_enable*]
#
#   Whether a service should be enabled to start at boot. Possible values are true and false.
#
# === Variables
#
# [*graphdb::restart_on_change*]
#
#   Whether a service should be restarted on service configuration change. Possible values are true and false.
#
# === Examples
#
#  graphdb::service::init { 'graphdb-service-init.d'
#     ensure         => 'present',
#     service_ensure => 'running',
#     service_enable => true,
#  }
#
define graphdb::service::init($ensure, $service_ensure, $service_enable) {

  File {
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
  }

  $notify_service = $graphdb::restart_on_change ? {
    true  => Service[$title],
    false => undef,
  }

  if ( $ensure == 'present' ) {
    file { "/etc/init.d/${title}":
      ensure  => $ensure,
      content => template('graphdb/service/init.d.erb'),
      before  => Service[$title],
      notify  => $notify_service,
    }
  } else {
    file { "/etc/init.d/${title}":
      ensure    => 'absent',
      subscribe => Service[$title],
    }
  }

  service { $title:
    ensure     => $service_ensure,
    enable     => $service_enable,
    name       => $title,
    provider   => 'init',
    hasstatus  => true,
    hasrestart => true,
  }

}
