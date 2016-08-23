define graphdb::data (
  $endpoint,
  $repository,
  $exists_query,
  $data = undef,
  $source = undef,
  $archive = undef,
  $data_format = undef,
  $context = 'null',
  $overwrite = true,
  $exists_expected_response = true,
  $timeout = 200,
) {
  require graphdb

  File {
    owner => $graphdb::graphdb_user,
    group => $graphdb::graphdb_group,
  }

  Exec {
    user => $graphdb::graphdb_user,
  }

  if $archive {
    $archive_name = basename($archive)
    $archive_base = "${graphdb::tmp_dir}/${title}"
    $archive_destination = "${archive_base}/${archive_name}.zip"
    $data_source_final = "${archive_base}/unpacked"

    file { $archive_base:
      ensure => directory,
    }

    file { $archive_destination:
      source  => $archive,
      require => File[$archive_base],
      notify  => Exec["unpack-archive-source-${title}"],
    }

    exec { "unpack-archive-source-${title}":
      command     => "rm -rf ${data_source_final} && unzip ${archive_destination} -d ${data_source_final}",
      refreshonly => true,
      require     => [Package['unzip'], File[$archive_base]],
      notify      => Graphdb_data[$title],
    }
  } else {
    $data_source_final = $source
  }

  graphdb_data { $title:
    endpoint                 => $endpoint,
    repository_id            => $repository,
    exists_query             => $exists_query,
    data_source              => $data_source_final,
    data                     => $data,
    data_format              => $data_format,
    data_context             => $context,
    data_overwrite           => $overwrite,
    exists_expected_response => $exists_expected_response ,
    timeout                  => $timeout,
  }
}
