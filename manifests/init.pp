class graphdb (
  $version,
  $edition,
  $ensure                  = $graphdb::params::ensure,
  $status                  = $graphdb::params::status,
  $tmp_dir                 = '/var/tmp/graphdb',
  $data_dir                = '/var/lib/graphdb',
  $log_dir                 = '/var/log/graphdb',
  $install_dir             = '/opt/graphdb',
  $manage_graphdb_user     = true,
  $java_home               = undef,
  $restart_on_change       = $graphdb::params::restart_on_change,
  $graphdb_user            = $graphdb::params::graphdb_user,
  $graphdb_group           = $graphdb::params::graphdb_group,
  $purge_data_dir          = $graphdb::params::purge_data_dir,
  $archive_dl_timeout      = $graphdb::params::archive_dl_timeout,
  $graphdb_download_url    = 'http://maven.ontotext.com/content/groups/all-onto/com/ontotext/graphdb/',
) inherits graphdb::params {

  anchor { 'graphdb::begin': }


  #### Validate parameters

  # version
  if versioncmp($version, '7.0.0') < 0 {
    fail('This module supprort GraphDB version 7.0.0 and up')
  }

  if ! ($edition in [ 'se', 'ee', 'EE', 'SE' ]) {
    fail("\"${edition}\" is not a valid edition parameter value")
  }

  # ensure
  if ! ($ensure in [ 'present', 'absent' ]) {
    fail("\"${ensure}\" is not a valid ensure parameter value")
  }

  # service status
  if ! ($status in [ 'enabled', 'disabled', 'running', 'unmanaged' ]) {
    fail("\"${status}\" is not a valid status parameter value")
  }

  validate_absolute_path($tmp_dir)
  validate_absolute_path($data_dir)
  validate_absolute_path($install_dir)

  validate_bool($manage_graphdb_user)

  validate_slength($graphdb_user, 32, 1)
  validate_slength($graphdb_group, 32, 1)
  validate_bool($purge_data_dir)
  validate_integer($archive_dl_timeout, undef, 100)

  if $java_home {
    validate_absolute_path($java_home)
    $java_location = $java_home
  }
  elsif $::machine_java_home {
    $java_location = $::machine_java_home
  } else {
    $java_location = '/usr/lib/jvm/java-8-oracle'
  }

  ensure_packages(['unzip'])

  File {
    owner => $graphdb_user,
    group => $graphdb_group,
  }

  $archive_dir = $tmp_dir

  $graphdb_user_ensure = $manage_graphdb_user ? {
    true  => $ensure,
    false => 'absent'
  }

  user { $graphdb_user:
    ensure  => $graphdb_user_ensure,
    comment => 'graphdb service user',
  }

  if $ensure == 'present' {
    file { [$install_dir, $tmp_dir, $data_dir]:
      ensure => 'directory',
    }

  } else {
    if $purge_data_dir {
      file { [$install_dir, $tmp_dir, $data_dir]:
        ensure => 'absent',
      }
    }
    file { $tmp_dir:
      ensure => 'absent',
    }
  }

  include graphdb::install
  include graphdb::tool_links

  #### Relationships

  if $ensure == 'present' {

    Anchor['graphdb::begin']
    -> Class['graphdb::install']
    -> Class['graphdb::tool_links']
    -> Graphdb::Instance <| |>

  } else {

  }

}
