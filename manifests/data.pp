# == Define: graphdb::data
#
#  This define allows you to import data from given source(incl. zip archive)
#
# === Parameters
#
# [*endpoint*]
#   GraphDB endpoint.
#   example: http://localhost:8080
#
# [*repository*]
#   GraphDB repository.
#
# [*exists_query*]
#   The ask query to check whether data is already loaded.
#   You can use the following syntax: ask {?s ?p ?o}
#
# [*exists_expected_response*]
#   The expected response from exists_query
#   default: true
#
# [*data*]
#  The data you want to load into GraphDB repository.
#  Supported formats:
#  String: 'data'
#  Array: ['data#1','data#2']
#  Array of Hashes: [{'content' => 'data#1', 'context' => 'context_of_data#1', 'format' => 'format_of_data1'},
#  {'content' => 'data#2', 'context' => 'context_of_data#2', 'format' => 'format_of_data2'}]
#  Mixed Array: [{'content' => 'data#1', 'context' => 'context_of_data#1', 'format' => 'format_of_data1'}, 'data#2']
#  note#1: if context for data not provided data_context is used
#  note#2: if format for data not provided data_format is used
#
# [*source*]
#  The source of data you want to load into GraphDB repository.
#  Supported formats:
#  String: 'path_to_file'
#  String: 'path_to_directory'
#  Array: ['path_to_file#1','path_to_file#2']
#  Array of Hashes: [{'source' => 'path_to_file#1', 'context' => 'context_of_file#1', 'format' => 'format_of_file#1'},
#  {'source' => 'path_to_file#2', 'context' => 'context_of_file#2', 'format' => 'format_of_file#2'}]
#  Mixed Array: [{'source' => 'path_to_file#1', 'context' => 'context_of_file#1', 'format' => 'format_of_file#1'},
#  'path_to_file#2']
#  note#1: if context for file not provided data_context is used
#  note#2: if format for file not provided trying to resolve format from file if fails data_format is used
#
# [*archive*]
#   Local zip archive that you want to load into GraphDB repository.
#
# [*data_format*]
#   The data format.
#   example: turtle
#
# [*context*]
#   The context you want to load your data into.
#  default: null
#
# [*overwrite*]
#   Wheather to overwrite any existing data.
#   default: false
#
# [*timeout*]
#   The max number of seconds that the loading process should wait before giving up.
#   default: 200
#
define graphdb::data (
  $endpoint,
  $repository,
  $exists_query,
  $data = undef,
  $source = undef,
  $archive = undef,
  $data_format = undef,
  $context = 'null',
  $overwrite = false,
  $exists_expected_response = true,
  $timeout = 200,
) {
  require graphdb

  File {
    owner => $graphdb::graphdb_user,
    group => $graphdb::graphdb_group,
  }

  Exec {
    path => [ '/bin', '/usr/bin', '/usr/local/bin' ],
    cwd  => '/',
    user => $graphdb::graphdb_user,
  }

  if $archive {
    $archive_name = basename($archive)
    $archive_base = "${graphdb::tmp_dir}/${title}"
    $archive_destination = "${archive_base}/${archive_name}"
    $data_source_final = "${archive_base}/unpacked"

    file { $archive_base:
      ensure => directory,
    }

    file { $archive_destination:
      ensure  => 'present',
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
