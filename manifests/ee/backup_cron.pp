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
    source  => $backup_script_source,
    owner   => $graphdb::graphdb_user,
    group   => $graphdb::graphdb_group,
    mode    => '0755',
  }

  cron { $title:
    ensure      => $ensure,
    command     => "${graphdb::install_dir}/${title} ${master_endpoint} ${master_repository} ${jolokia_secret} >> ${graphdb::install_dir}/${title}.log 2>&1",
    hour        => $hour,
    minute      => $minute,
    weekday     => $weekday,
    month       => $month,
    monthday    => $monthday,
    user        => $graphdb::graphdb_user,
    require     => [Package['curl'], File["${graphdb::install_dir}/${title}"]],
  }

}
