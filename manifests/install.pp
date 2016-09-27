class graphdb::install {

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

  $archive_destination = "${graphdb::tmp_dir}/graphdb-${graphdb::edition}-${graphdb::version}.zip"
  $dist_installation_dir = "${graphdb::install_dir}/dist"
  $instances_installation_dir = "${graphdb::install_dir}/instances"

  if $graphdb::ensure == 'present' {

    file { $instances_installation_dir:
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
      require     => Package['unzip'],
    }

  } else {
    file { [$archive_destination, $dist_installation_dir, $instances_installation_dir]:
      ensure => $graphdb::ensure,
    }
  }


}
