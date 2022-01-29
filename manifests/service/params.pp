# == Class: graphdb::service::params
#
# This class exists to
# 1. Manage internally used module variables in a central place.
#
# === Parameters
#
# This class does not provide any parameters.
#
# === Examples
#
# This class is not intended to be used directly.
#
class graphdb::service::params {
  $operatingsystem = $facts['operatingsystem'] # lint:ignore:legacy_facts
  $operatingsystemmajrelease = $facts['operatingsystemmajrelease'] # lint:ignore:legacy_facts

  # OS service manager
  case $operatingsystem {
    'RedHat', 'CentOS', 'Fedora', 'Scientific', 'OracleLinux', 'SLC': {
      if versioncmp($operatingsystemmajrelease, '7') >= 0 {
        $service_provider= 'systemd'
        $systemd_service_path = '/lib/systemd/system'
      } else {
        $service_provider= 'init'
        $systemd_service_path = undef
      }
    }
    'Amazon': {
      if versioncmp($operatingsystemmajrelease, '2') >= 0 {
        $service_provider= 'systemd'
        $systemd_service_path = '/lib/systemd/system'
      } else {
        $service_provider= 'init'
        $systemd_service_path = undef
      }
    }
    'Debian': {
      if versioncmp($operatingsystemmajrelease, '8') >= 0 {
        $service_provider= 'systemd'
        $systemd_service_path = '/lib/systemd/system'
      } else {
        $service_provider= 'init'
        $systemd_service_path = undef
      }
    }
    'Ubuntu': {
      if versioncmp($operatingsystemmajrelease, '15') >= 0 {
        $service_provider= 'systemd'
        $systemd_service_path = '/lib/systemd/system'
      } else {
        $service_provider= 'upstart'
        $systemd_service_path = undef
      }
    }
    'OpenSuSE': {
      $service_provider     = 'systemd'
      if versioncmp($operatingsystemmajrelease, '12') <= 0 {
        $systemd_service_path = '/lib/systemd/system'
      } else {
        $systemd_service_path = '/usr/lib/systemd/system'
      }
    }
    'OpenBSD': {
      $service_provider    = 'openbsd'
      $systemd_service_path = undef
    }
    default: {
      fail("\"${module_name}\" provides no service parameters for \"${operatingsystem}\"")
    }
  }
}
