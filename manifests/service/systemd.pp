# == Define: graphdb::service::systemd
#
# Installs systemd configuration and defines service with systemd provider
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
# [*graphdb::params::systemd_service_path*]
#
#   The path of OS specific systemd configuration directory.
#
# === Examples
#
#  graphdb::service::systemd { 'graphdb-service-systemd'
#     ensure         => 'present',
#     service_ensure => 'running',
#     service_enable => true,
#  }
#
define graphdb::service::systemd($ensure, $service_ensure, $service_enable, $kill_timeout = 180) {

  require graphdb::params

  File {
    owner   => 'root',
    group   => 'root',
  }

  Exec {
    path => [ '/bin', '/usr/bin', '/usr/local/bin' ],
  }

  $notify_service = $graphdb::restart_on_change ? {
    true  => [ Exec["systemd_reload_${title}"], Service[$title] ],
    false => Exec["systemd_reload_${title}"]
  }

  if ( $ensure == 'present' ) {
    file { "${graphdb::params::systemd_service_path}/${title}.service":
      ensure  => $ensure,
      content => template('graphdb/service/systemd.erb'),
      before  => Service[$title],
      notify  => $notify_service,
    }

    $service_require = Exec["systemd_reload_${title}"]

  } else {
    file { "${graphdb::params::systemd_service_path}/${title}.service":
      ensure    => 'absent',
      subscribe => Service[$title],
      notify    => Exec["systemd_reload_${title}"],
    }

    $service_require = undef
  }

  exec { "systemd_reload_${title}":
    command     => '/bin/systemctl daemon-reload',
    refreshonly => true,
  }

  service { $title:
    ensure     => $service_ensure,
    enable     => $service_enable,
    name       => "${title}.service",
    hasstatus  => true,
    hasrestart => true,
    provider   => 'systemd',
    require    => $service_require,
  }

}
