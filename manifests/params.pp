# == Class: graphdb::params
#
# This class exists to
# 1. Declutter the default value assignment for class parameters.
# 2. Manage internally used module variables in a central place.
#
# === Parameters
#
# This class does not provide any parameters.
#
# === Variables
#
# [*operatingsystem*]
#
#   Operating system
#
# [*operatingsystemmajrelease*]
#
#   Operating system major release
#
# === Examples
#
# This class is not intended to be used directly.
#
class graphdb::params {

  # ensure
  $ensure = 'present'

  # service status
  $status = 'enabled'

  # restart on configuration change?
  $restart_on_change = true

  # Purge data directory
  $purge_data_dir = false

  # archive download timeout
  $archive_dl_timeout = 600

  $pid_dir = '/var/run/graphdb'

  # User and group to be runned as service
  case $::kernel {
    'Linux': {
      $graphdb_user  = 'graphdb'
      $graphdb_group = 'graphdb'
    }
    'Darwin': {
      $graphdb_user  = 'graphdb'
      $graphdb_group = 'graphdb'
    }
    'OpenBSD': {
      $graphdb_user  = '_graphdb'
      $graphdb_group = '_graphdb'
    }
    default: {
      fail("\"${module_name}\" provides no user/group default value
           for \"${::kernel}\"")
    }
  }

  # OS service manager
  case $::operatingsystem {
    'RedHat', 'CentOS', 'Fedora', 'Scientific', 'OracleLinux', 'SLC': {
      if versioncmp($::operatingsystemmajrelease, '7') >= 0 {
        $service_providers= 'systemd'
        $systemd_service_path = '/lib/systemd/system'
      } else {
        $service_providers= 'init'
        $systemd_service_path = undef
      }
    }
    'Amazon': {
      $service_providers    = 'init'
      $systemd_service_path = undef
    }
    'Debian': {
      if versioncmp($::operatingsystemmajrelease, '8') >= 0 {
        $service_providers= 'systemd'
        $systemd_service_path = '/lib/systemd/system'
      } else {
        $service_providers= 'init'
        $systemd_service_path = undef
      }
    }
    'Ubuntu': {
      if versioncmp($::operatingsystemmajrelease, '15') >= 0 {
        $service_providers= 'systemd'
        $systemd_service_path = '/lib/systemd/system'
      } else {
        $service_providers= 'upstart'
        $systemd_service_path = undef
      }
    }
    'OpenSuSE': {
      $service_providers     = 'systemd'
      if versioncmp($::operatingsystemmajrelease, '12') <= 0 {
        $systemd_service_path = '/lib/systemd/system'
      } else {
        $systemd_service_path = '/usr/lib/systemd/system'
      }
    }
    'OpenBSD': {
      $service_providers    = 'openbsd'
      $systemd_service_path = undef
    }
    default: {
      fail("\"${module_name}\" provides no service parameters
            for \"${::operatingsystem}\"")
    }
  }

}
