# == Define: graphdb::service::upstart
#
# Installs upstart configuration and defines service with upstart provider
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
#  graphdb::service::upstart { 'graphdb-service-upstart'
#     ensure         => 'present',
#     service_ensure => 'running',
#     service_enable => true,
#  }
#
define graphdb::service::upstart($ensure, $service_ensure, $service_enable) {

  File {
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
  }

  $notify_service = $graphdb::restart_on_change ? {
    true  => Service[$title],
    false => undef,
  }

  if ( $ensure == 'present' ) {
    file { "/etc/init/${title}.conf":
      ensure  => $ensure,
      content => template('graphdb/service/upstart.erb'),
      before  => Service[$title],
      notify  => $notify_service,
    }
  } else {
    file { "/etc/init/${title}.conf":
      ensure    => 'absent',
      subscribe => Service[$title],
    }
  }

  service { $title:
    ensure     => $service_enable,
    enable     => $service_enable,
    name       => $title,
    provider   => 'upstart',
    hasstatus  => true,
    hasrestart => true,
  }

}
