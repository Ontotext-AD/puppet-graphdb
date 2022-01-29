# == Define: graphdb::service::systemd
#
# Installs systemd configuration and defines service with systemd provider
#
# === Parameters
#
# [*ensure*]
#   Whether the service should exist. Possible values are present and absent.
#
# [*service_ensure*]
#   Whether a service should be running. Possible values are running, stopped, true and false.
#
# [*service_enable*]
#   Whether a service should be enabled to start at boot. Possible values are true and false.
#
# [*java_opts*]
#   Array of java options to give to GraphDB java process
#   example: ['-Xmx1g', '-Xms1g']
#
# [*kill_timeout*]
#   Time before force kill of GraphDB process. Instances with big repositories may
#   time to flush on shutdown.
#   default: 180
#
define graphdb::service::systemd (
  String $ensure,
  Boolean $service_enable,
  Optional[String] $service_ensure  = undef,
  Array $java_opts                  = [],
  Integer $kill_timeout             = 180
) {
  require graphdb::service::params

  $final_java_opts = generate_java_opts_string($java_opts)

  File {
    owner   => 'root',
    group   => 'root',
  }

  Exec { path => ['/bin', '/usr/bin', '/usr/local/bin'], }

  $notify_service = $graphdb::restart_on_change ? {
    true  => [Exec["systemd_reload_${title}"], Service["graphdb-${title}"]],
    false => Exec["systemd_reload_${title}"]
  }

  if ( $ensure == 'present' ) {
    file { "${graphdb::service::params::systemd_service_path}/graphdb-${title}.service":
      ensure  => $ensure,
      content => template('graphdb/service/systemd.erb'),
      before  => Service["graphdb-${title}"],
      notify  => $notify_service,
    }
    $service_require = Exec["systemd_reload_${title}"]
  } else {
    file { "${graphdb::service::params::systemd_service_path}/graphdb-${title}.service":
      ensure    => 'absent',
      subscribe => Service["graphdb-${title}"],
      notify    => Exec["systemd_reload_${title}"],
    }
    $service_require = undef
  }

  exec { "systemd_reload_${title}":
    command     => '/bin/systemctl daemon-reload',
    refreshonly => true,
  }

  service { "graphdb-${title}":
    ensure    => $service_ensure,
    enable    => $service_enable,
    name      => "graphdb-${title}.service",
    hasstatus => true,
    provider  => 'systemd',
    require   => $service_require,
  }
}
