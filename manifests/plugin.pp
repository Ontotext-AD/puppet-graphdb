define graphdb::plugin(
  $instance,
  $ensure = $graphdb::ensure,
  $source = undef,
) {

  require graphdb

  $instance_plugins_dir = "${graphdb::data_dir}/${instance}/plugins"

  $plugin_file_name = basename($source)

  file { "${instance_plugins_dir}/${plugin_file_name}":
    ensure => $ensure,
    source => $source,
  } ~>
  exec { "unpack-graphdb-plugin-${title}":
    command     => "rm -rf ${title} && unzip ${instance_plugins_dir}/${plugin_file_name} -d ${instance_plugins_dir}",
    refreshonly => true,
    require     => Package['unzip'],
    notify      => Service["graphdb-${instance}"],
  }

}
