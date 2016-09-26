define graphdb::instance (
  $license,
  $ensure             = $graphdb::ensure,
  $status             = $graphdb::status,
  $http_port          = 8080,
  $kill_timeout       = 180,
  $jolokia_secret     = undef,
  $extra_properties   = {},
  $java_opts          = [],
){
  include graphdb::install

  validate_string($license)
  validate_string($jolokia_secret)

  File {
    owner => $graphdb::graphdb_user,
    group => $graphdb::graphdb_group,
  }

  $service_name = "graphdb-${title}"

  $instance_home_dir = "${graphdb::install_dir}/instances/${title}"

  $license_file_name = basename($license)
  $licence_file_destination = "${instance_home_dir}/${license_file_name}"

  file { $licence_file_destination:
    ensure => $ensure,
    source => $license,
    mode   => '0555',
    notify => Service[$service_name],
  }

  $instance_data_dir = "${graphdb::data_dir}/${title}"
  $instance_plugins_dir = "${instance_data_dir}/plugins"
  $instance_temp_dir = "${graphdb::tmp_dir}/${title}"
  $instance_conf_dir = "${instance_home_dir}/conf"


  if $ensure == 'present' {
    file { [$instance_home_dir, $instance_data_dir, $instance_plugins_dir, $instance_temp_dir, $instance_conf_dir]:
      ensure => 'directory',
      notify => Service[$service_name],
    }
  } else {
    file { [$instance_home_dir, $instance_data_dir, $instance_plugins_dir, $instance_temp_dir, $instance_conf_dir]:
      ensure => $ensure,
    }
  }

  $default_properties = {
    'graphdb.home.data'      => "${graphdb::data_dir}/${title}",
    'graphdb.home.logs'      => "${graphdb::log_dir}/${title}",
    'graphdb.license.file'   => $licence_file_destination,
    'graphdb.connector.port' => $http_port,
    'graphdb.extra.plugins'  => $instance_plugins_dir,
  }

  if $jolokia_secret {
    $final_graphdb_properties = merge($default_properties, { 'graphdb.jolokia.secret' => $jolokia_secret }, $extra_properties)
  } else {
    $final_graphdb_properties = merge($default_properties, $extra_properties)
  }

  file { "${instance_home_dir}/conf/graphdb.properties":
    ensure  => $ensure,
    content => template('graphdb/config/graphdb.properties.erb'),
    notify  => Service[$service_name],
  }

  graphdb::service { $title:
    ensure       => $ensure,
    status       => $status,
    java_opts    => $java_opts,
    kill_timeout => $kill_timeout,
  }

  if $ensure == 'present' {
    graphdb_validator { $service_name: endpoint => "http://${::ipaddress}:${http_port}", subscribe => Service[$service_name] }
  }

  Class['graphdb::install'] ~> Graphdb::Instance <| |>

}
