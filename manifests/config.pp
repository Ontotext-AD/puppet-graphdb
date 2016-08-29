define graphdb::config (
  $license,
  $http_port,
  $jolokia_secret         = undef,
  $extra_properties       = undef,
) {

  $instance_home_dir = "${graphdb::install_dir}/instances/${title}"

  $default_properties = {
    'graphdb.home.data'      => "${graphdb::data_dir}/${title}",
    'graphdb.home.logs'      => "${graphdb::log_dir}/${title}",
    'graphdb.license.file'   => $license,
    'graphdb.connector.port' => $http_port,
  }

  if $jolokia_secret {
    $jolokia_secret_property = { 'graphdb.jolokia.secret' => $jolokia_secret }
  }

  $final_graphdb_properties = merge($default_properties, $jolokia_secret_property, $extra_properties)

  file { "${instance_home_dir}/conf":
    ensure => 'directory',
  }

  file { "${instance_home_dir}/conf/graphdb.properties":
    ensure  => 'present',
    content => template('graphdb/config/graphdb.properties.erb'),
    notify  => Service[$title],
  }

}
