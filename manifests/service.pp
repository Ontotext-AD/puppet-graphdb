# == Define: graphdb::service
#
# Based on parameters passed defines init.d, systemd or upstart service
#
# === Parameters
#
# [*ensure*]
#
#   Whether the service should exist. Possible values are present and absent.
#
# [*status*]
#
#   What the state of the service must be. Possible values are enabled, disabled, running and unmanaged.
#
# === Variables
#
# [*graphdb::params::service_providers*]
#
#   The path of OS specific service provider.
#
# === Examples
#
#  graphdb::service { 'graphdb-service'
#     ensure         => 'present',
#     status         => 'enabled',
#  }
#
define graphdb::service($ensure, $status, $java_opts = [], $kill_timeout = 180) {
  require graphdb::params

  #### Service management

  # set params: in operation
  if $ensure == 'present' {

    case $status {
      # make sure service is currently running, start it on boot
      'enabled': {
        $service_ensure = 'running'
        $service_enable = true
      }
      # make sure service is currently stopped, do not start it on boot
      'disabled': {
        $service_ensure = 'stopped'
        $service_enable = false
      }
      # make sure service is currently running, do not start it on boot
      'running': {
        $service_ensure = 'running'
        $service_enable = false
      }
      # do not start service on boot, do not care whether currently running
      # or not
      'unmanaged': {
        $service_ensure = undef
        $service_enable = false
      }
      # unknown status
      # note: don't forget to update the parameter check in init.pp if you
      #       add a new or change an existing status.
      default: {
        fail("\"${status}\" is an unknown service status value")
      }
    }

  } else {
    $service_ensure = 'stopped'
    $service_enable = false
  }

  case $graphdb::params::service_providers {
    'init': {
      graphdb::service::init { $title:
        ensure         => $ensure,
        service_ensure => $service_ensure,
        service_enable => $service_enable,
        java_opts      => $java_opts,
      }
    }
    'upstart': {
      graphdb::service::upstart { $title:
        ensure         => $ensure,
        service_ensure => $service_ensure,
        service_enable => $service_enable,
        java_opts      => $java_opts,
        kill_timeout   => $kill_timeout,
      }
    }
    'systemd': {
      graphdb::service::systemd { $title:
        ensure         => $ensure,
        service_ensure => $service_ensure,
        service_enable => $service_enable,
        java_opts      => $java_opts,
        kill_timeout   => $kill_timeout,
      }
    }
    default: {
      fail("Unknown service provider ${graphdb::params::service_providers}")
    }

  }

}
