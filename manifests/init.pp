# == Class: graphdb
#
# This class is able to install or remove graphdb distribution on a node.
# It manages the status of the related service.
#
# === Parameters
#
# [*ensure*]
#   String. Controls if the managed resources shall be <tt>present</tt> or
#   <tt>absent</tt>. If set to <tt>absent</tt>:
#   * The managed distribution is being uninstalled.
#   * Any traces of installation will be purged as good as possible. This may
#     include existing configuration files. The exact behavior is provider
#     dependent. Q.v.:
#     * Puppet type reference: {package, "purgeable"}[http://j.mp/xbxmNP]
#     * {Puppet's package provider source code}[http://j.mp/wtVCaL]
#   * System modifications (if any) will be reverted as good as possible
#     (e.g. removal of created users, services, changed log settings, ...).
#   * This is thus destructive and should be used with care.
#   Defaults to <tt>present</tt>.
#
# [*version*]
#   String. GraphDB version to install
#
# [*edition*]
#   String. GraphDB edition to install
#
# [*status*]
#   String to define the status of the service. Possible values:
#   * <tt>enabled</tt>: Service is running and will be started at boot time.
#   * <tt>disabled</tt>: Service is stopped and will not be started at boot
#     time.
#   * <tt>running</tt>: Service is running but will not be started at boot time.
#     You can use this to start a service on the first Puppet run instead of
#     the system startup.
#   * <tt>unmanaged</tt>: Service will not be started at boot time and Puppet
#     does not care whether the service is running or not. For example, this may
#     be useful if a cluster management software is used to decide when to start
#     the service plus assuring it is running on the desired node.
#   Defaults to <tt>enabled</tt>. The singular form ("service") is used for the
#   sake of convenience. Of course, the defined status affects all services if
#   more than one is managed (see <tt>service.pp</tt> to check if this is the
#   case).
#
# [*tmp_dir*]
#   String. The location of temporary files that this module will use
#
# [*data_dir*]
#   String. GraphDB data directory
#
# [*log_dir*]
#   String. GraphDB log directory
#
# [*install_dir*]
#   String. GraphDB distribution location
#
# [*manage_graphdb_user*]
#   Boolean. Whether this module manages GraphDB user
#
# [*graphdb_user*]
#   String. The group GraphDB should run as. This also sets the file rights
#
# [*graphdb_group*]
#   String. The group GraphDB should run as. This also sets the file rights
#
# [*java_home*]
#   String. The location of java installation
#
# [*restart_on_change*]
#   Boolean that determines if the application should be automatically restarted
#   whenever the configuration change. Enabling this
#   setting will cause GraphDB to restart whenever there is cause to
#   re-read configuration files, load new plugins, or start the service using an
#   updated/changed executable. This may be undesireable in highly available
#   environments.
#
# [*purge_data_dir*]
#   Boolean. Purge data directory on removal
#
# [*archive_dl_timeout*]
#   For http downloads you can set howlong the exec resource may take.
#   default: 600 seconds
#
# [*graphdb_download_url*]
#   Url to the archive to download.
#   This can be a http or https resource for remote packages
#   puppet:// resource or file:/ for local packages
#
class graphdb (
  $version                 = undef,
  $edition                 = undef,
  $ensure                  = $graphdb::params::ensure,
  $status                  = $graphdb::params::status,
  $tmp_dir                 = '/var/tmp/graphdb',
  $data_dir                = '/var/lib/graphdb',
  $log_dir                 = '/var/log/graphdb',
  $install_dir             = '/opt/graphdb',
  $manage_graphdb_user     = true,
  $graphdb_user            = $graphdb::params::graphdb_user,
  $graphdb_group           = $graphdb::params::graphdb_group,
  $java_home               = undef,
  $restart_on_change       = $graphdb::params::restart_on_change,
  $purge_data_dir          = $graphdb::params::purge_data_dir,
  $archive_dl_timeout      = $graphdb::params::archive_dl_timeout,
  $graphdb_download_url    = 'http://maven.ontotext.com/content/groups/all-onto/com/ontotext/graphdb',
) inherits graphdb::params {

  #### Validate parameters

  # ensure
  if ! ($ensure in [ 'present', 'absent' ]) {
    fail("\"${ensure}\" is not a valid ensure parameter value")
  }

  if ($ensure  == 'present') {
    if  (!$version or !$edition){
      fail('"ensure" is set on present, you should provide "version" and "edition"')
    }

    # version
    if versioncmp($version, '7.0.0') < 0 {
      fail('This module supprort GraphDB version 7.0.0 and up')
    }

    if ! ($edition in [ 'se', 'ee' ]) {
      fail("\"${edition}\" is not a valid edition parameter value")
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
  }

  include graphdb::install
  include graphdb::tool_links

  #### Relationships

  if $ensure == 'present' {
    Class['graphdb::install']
    -> Class['graphdb::tool_links']
    -> Graphdb::Instance <| |>
  } else {
    Graphdb::Instance <| |> -> Class['graphdb::install']
  }

}
