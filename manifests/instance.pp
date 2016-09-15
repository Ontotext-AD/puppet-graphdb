define graphdb::instance (
  $license,
  $http_port          = '8080',
  $kill_timeout       = '180',
  $jolokia_secret     = undef,
  $extra_properties   = undef,
){
  include graphdb::install

  validate_string($license)
  validate_string($jolokia_secret)

  File {
    owner => $graphdb::graphdb_user,
    group => $graphdb::graphdb_group,
  }

  $instance_home_dir = "${graphdb::install_dir}/instances/${title}"

  $license_file_name = basename($license)
  $licence_file_destination = "${instance_home_dir}/${license_file_name}"

  file { $licence_file_destination:
    ensure => $graphdb::ensure,
    source => $license,
    mode   => '0555',
    notify => Service[$title],
  }

  $instance_data_dir = "${graphdb::data_dir}/${title}"
  $instance_plugins_dir = "${instance_data_dir}/plugins"
  $instance_temp_dir = "${graphdb::tmp_dir}/${title}"


  if $graphdb::ensure == 'present' {
    file { [$instance_home_dir, $instance_data_dir, $instance_plugins_dir, $instance_temp_dir]:
      ensure => 'directory',
      notify => Service[$title],
    }
  } else {
    file { [$instance_home_dir, $instance_data_dir, $instance_plugins_dir, $instance_temp_dir]:
      ensure => $graphdb::ensure,
    }
  }

  $default_properties = {
    'graphdb.home.data'      => "${graphdb::data_dir}/${title}",
    'graphdb.home.logs'      => "${graphdb::log_dir}/${title}",
    'graphdb.license.file'   => $licence_file_destination,
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

  graphdb::service { $title:
    ensure => $graphdb::ensure,
    status => $graphdb::status,
  }

  graphdb_validator { $title: endpoint => "http://${::ipaddress}:${http_port}" }

  Class['graphdb::install'] ~> Graphdb::Instance <| |>

}
