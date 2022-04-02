# == Class: graphdb::install
#
# Perform the actual download of distribution archive and installations.
# Not meant to be used directly.
#
class graphdb::install {
  require graphdb

  Exec {
    path => ['/bin', '/usr/bin', '/usr/local/bin'],
    cwd  => '/',
    user => $graphdb::graphdb_user,
  }

  $archive_destination = "${graphdb::tmp_dir}/graphdb-${graphdb::edition}-${graphdb::version}.zip"
  $dist_installation_dir = "${graphdb::install_dir}/dist"
  $instances_installation_dir = "${graphdb::install_dir}/instances"
  $import_installation_dir = $graphdb::import_dir

  if $graphdb::ensure == 'present' {
    File {
      owner => $graphdb::graphdb_user,
      group => $graphdb::graphdb_group,
    }

    ensure_packages(['unzip', 'curl'])

    if $graphdb::manage_graphdb_user {
      user { $graphdb::graphdb_user:
        ensure  => 'present',
        comment => 'graphdb service user',
      }
    }

    file { [$graphdb::install_dir, $graphdb::tmp_dir, $graphdb::data_dir, $graphdb::log_dir,
      $graphdb::pid_dir, $instances_installation_dir, $import_installation_dir]:
        ensure => 'directory',
    }

    $_package_url_path="${graphdb::graphdb_download_url}/graphdb-${graphdb::edition}/${graphdb::version}"
    $_package_url_file="graphdb-${graphdb::edition}-${graphdb::version}-dist.zip"
    $package_url = "${_package_url_path}/${_package_url_file}"
    $unpacked_directory = "${dist_installation_dir}/graphdb-${graphdb::edition}-${graphdb::version}"

    if $graphdb::graphdb_download_user {
      $basic_auth_option = "-u ${graphdb::graphdb_download_user}:${graphdb::graphdb_download_password}"
    } else {
      $basic_auth_option = ''
    }

    $_download_cmd_rm="rm -f ${graphdb::tmp_dir}/*.zip"
    $_download_cmd_curl="curl --insecure ${basic_auth_option} -o ${archive_destination} ${package_url} 2> /dev/null"
    $_unpack_cmd_1="rm -rf ${dist_installation_dir}"
    $_unpack_cmd_2="unzip ${archive_destination} -d ${dist_installation_dir}"
    $_unpack_cmd_3="mv ${unpacked_directory}/* ${dist_installation_dir}"
    $_unpack_cmd_4="rm -r ${unpacked_directory}"
    exec { "download-graphdb-${graphdb::edition}-${graphdb::version}-archive":
      command => "${_download_cmd_rm} && ${_download_cmd_curl}",
      creates => $archive_destination,
      timeout => $graphdb::archive_dl_timeout,
      require => [File[$graphdb::tmp_dir], Package['curl']],
    }
    ~> exec { 'unpack-graphdb-archive':
      command     => "${_unpack_cmd_1} && ${_unpack_cmd_2} && ${_unpack_cmd_3} && ${_unpack_cmd_4}",
      refreshonly => true,
      require     => [File[$graphdb::install_dir], Package['unzip']],
    }
  } else {
    $purge_list = [$graphdb::install_dir, $graphdb::tmp_dir, $graphdb::log_dir, $graphdb::pid_dir, $graphdb::import_dir]

    if $graphdb::purge_data_dir {
      join($purge_list, $graphdb::data_dir)
    }

    if $graphdb::manage_graphdb_user {
      user { $graphdb::graphdb_user:
        ensure  => 'absent',
      }
    }

    file { $purge_list:
      ensure  => 'absent',
      force   => true,
      backup  => false,
      recurse => true,
    }
  }
}
