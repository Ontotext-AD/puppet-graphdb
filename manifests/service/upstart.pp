# == Define: graphdb::service::upstart
#
# Installs upstart configuration and defines service with upstart provider
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
define graphdb::service::upstart($ensure, $service_ensure, $service_enable, $java_opts = [], $kill_timeout = 180) {

  $final_java_opts = generate_java_opts_string($java_opts)

  File {
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
  }

  $notify_service = $graphdb::restart_on_change ? {
    true  => Service["graphdb-${title}"],
    false => undef,
  }

  if ( $ensure == 'present' ) {
    file { "/etc/init/graphdb-${title}.conf":
      ensure  => $ensure,
      content => template('graphdb/service/upstart.erb'),
      before  => Service["graphdb-${title}"],
      notify  => $notify_service,
    }
  } else {
    file { "/etc/init/graphdb-${title}.conf":
      ensure    => 'absent',
      subscribe => Service["graphdb-${title}"],
    }
  }

  service { "graphdb-${title}":
    ensure    => $service_ensure,
    enable    => $service_enable,
    provider  => 'upstart',
    hasstatus => true,
  }

}
