define graphdb::config (
  $license,
  $http_port,
  $log_configuration_file = undef,
  $extra_properties       = undef,
) {

  $instance_home_dir = "${graphdb::install_dir}/instances/${title}"

  $default_properties = {
    'graphdb.home.data'      => "${graphdb::data_dir}/${title}",
    'graphdb.home.logs'      => "${graphdb::log_dir}/${title}",
    'graphdb.license.file'   => $license,
    'graphdb.connector.port' => $http_port,
  }

  $final_graphdb_properties = merge($default_properties, $extra_properties)

  file { "${instance_home_dir}/conf":
    ensure => 'directory',
  }

  file { "${instance_home_dir}/conf/graphdb.properties":
    ensure  => 'present',
    content => template('graphdb/config/graphdb.properties.erb'),
    notify  => Service[$title],
  }

}
