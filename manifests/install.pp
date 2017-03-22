# == Class: graphdb::install
#
# Perform the actual download of distribution archive and installations.
# Not meant to be used directly.
#
class graphdb::install {

  require graphdb

  Exec {
    path => [ '/bin', '/usr/bin', '/usr/local/bin' ],
    cwd  => '/',
    user => $graphdb::graphdb_user,
  }

  $archive_destination = "${graphdb::tmp_dir}/graphdb-${graphdb::edition}-${graphdb::version}.zip"
  $dist_installation_dir = "${graphdb::install_dir}/dist"
  $instances_installation_dir = "${graphdb::install_dir}/instances"

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

    file { [$graphdb::install_dir, $graphdb::tmp_dir, $graphdb::data_dir, $instances_installation_dir]:
      ensure => 'directory',
    }

    $package_url = "${graphdb::graphdb_download_url}/graphdb-${graphdb::edition}/${graphdb::version}/graphdb-${graphdb::edition}-${graphdb::version}-dist.zip"
    $unpacked_directory = "${dist_installation_dir}/graphdb-${graphdb::edition}-${graphdb::version}"

    exec { "download-graphdb-${graphdb::edition}-${graphdb::version}-archive":
      command => "rm -f ${graphdb::tmp_dir}/*.zip && curl --insecure -o ${archive_destination} ${package_url} 2> /dev/null",
      creates => $archive_destination,
      timeout => $graphdb::archive_dl_timeout,
      require => [File[$graphdb::tmp_dir], Package['curl']],
    } ~>
    exec { 'unpack-graphdb-archive':
      command     => "rm -rf ${dist_installation_dir} && unzip ${archive_destination} -d ${dist_installation_dir} && mv ${unpacked_directory}/* ${dist_installation_dir} && rm -r ${unpacked_directory}",
      refreshonly => true,
      require     => [File[$graphdb::install_dir], Package['unzip']],
    }

  } else {
    $purge_list = [$graphdb::install_dir, $graphdb::tmp_dir, $graphdb::log_dir]

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
