# == Define: graphdb::ee::backup_cron
#
# This define is able to setup automatic backup cron job for GraphDB repository
#
# === Parameters
#
# [*ensure*]
#   String. Controls if the managed resources shall be <tt>present</tt> or
#   <tt>absent</tt>. If set to <tt>absent</tt>:
#   * The managed cron job and backup script is being uninstalled.
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
# [*master_endpoint*]
#   GraphDB master endpoint.
#   example: http://localhost:8080
#
# [*master_repository*]
#   GraphDB master repository.
#
# [*jolokia_secret*]
#   GraphDB jolokia secret for http jmx requests
#
# [*backup_script_source*]
#   The source of backup script
#
# For other properties, please, check Cron job properties
#
define graphdb::ee::backup_cron (
  $master_endpoint,
  $master_repository,
  $jolokia_secret,
  $ensure               = $graphdb::ensure,
  $backup_script_source = 'puppet:///modules/graphdb/cron/backup.sh',
  $hour                 = undef,
  $minute               = undef,
  $weekday              = undef,
  $month                = undef,
  $monthday             = undef,
) {
  require graphdb

  ensure_packages(['curl'])

  file { "${graphdb::install_dir}/${title}":
    ensure => $ensure,
    source => $backup_script_source,
    owner  => $graphdb::graphdb_user,
    group  => $graphdb::graphdb_group,
    mode   => '0755',
  }

  cron { $title:
    ensure   => $ensure,
    command  => "${graphdb::install_dir}/${title} ${master_endpoint} ${master_repository} ${jolokia_secret} >> ${graphdb::install_dir}/${title}.log 2>&1",
    hour     => $hour,
    minute   => $minute,
    weekday  => $weekday,
    month    => $month,
    monthday => $monthday,
    user     => $graphdb::graphdb_user,
    require  => [Package['curl'], File["${graphdb::install_dir}/${title}"]],
  }

}
