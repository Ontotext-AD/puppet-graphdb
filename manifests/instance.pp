# == Define: graphdb::instance
#
#  This define allows you to create or remove an graphdb instance
#
# === Parameters
#
# [*ensure*]
#   String. Controls if the managed resources shall be <tt>present</tt> or
#   <tt>absent</tt>. If set to <tt>absent</tt>:
#   * The managed instance is being uninstalled.
#   * Any traces of installation will be purged as good as possible. This may
#     include existing configuration files. The exact behavior is provider
#     dependent. Q.v.:
#     * Puppet type reference: {package, "purgeable"}[http://j.mp/xbxmNP]
#     * {Puppet's package provider source code}[http://j.mp/wtVCaL]
#   * System modifications (if any) will be reverted as good as possible
#     (e.g. removal of created users, services, changed log settings, ...).
#   * This is thus destructive and should be used with care.
#   Defaults to <tt>present</tt>.
#
# [*status*]
#   String to define the status of the service. Possible values:
#   * <tt>enabled</tt>: Service is running and will be started at boot time.
#   * <tt>disabled</tt>: Service is stopped and will not be started at boot
#     time.
#   * <tt>running</tt>: Service is running but will not be started at boot time.
#     You can use this to start a service on the first Puppet run instead of
#     the system startup.
#   * <tt>unmanaged</tt>: Service will not be started at boot time and Puppet
#     does not care whether the service is running or not. For example, this may
#     be useful if a cluster management software is used to decide when to start
#     the service plus assuring it is running on the desired node.
#   Defaults to <tt>enabled</tt>. The singular form ("service") is used for the
#   sake of convenience. Of course, the defined status affects all services if
#   more than one is managed (see <tt>service.pp</tt> to check if this is the
#   case).
#
# [*license*]
#   GraphDB license file.
#
# [*http_port*]
#   The http port at which GraphDB will run.
#
# [*kill_timeout*]
#   Time before force kill of GraphDB process. Instances with big repositories may
#   time to flush on shutdown.
#   default: 180
#
# [*validator_timeout*]
#   Time before GraphDB validator decides that the GraphDB instance is not running
#
# [*heap_size*]
#   GraphDB  java heap size given by -Xmx parameter. Note heap_size parameter will also set xms=xmx
#
# [*jolokia_secret*]
#   GraphDB jolokia secret for http jmx requests
#
# [*logback_config*]
#   GraphDB logback log configuration
#
# [*extra_properties*]
#   Hash of properties to include in graphdb.properties file
#   example: {'graphdb.some.property' => 'some.property.value'}
#
# [*java_opts*]
#   Array of java options to give to GraphDB java process
#   example: ['-Xmx1g', '-Xms1g']
#
define graphdb::instance (
  $license           = undef,
  $ensure            = $graphdb::ensure,
  $status            = $graphdb::status,
  $http_port         = 8080,
  $kill_timeout      = 180,
  $validator_timeout = 60,
  $heap_size         = undef,
  $jolokia_secret    = undef,
  $logback_config    = undef,
  $extra_properties  = { },
  $java_opts         = [],
) {

  # ensure
  if !($ensure in [ 'present', 'absent' ]) {
    fail("\"${ensure}\" is not a valid ensure parameter value")
  }

  if $ensure == 'present' {
    validate_string($license)
    if $jolokia_secret {
      validate_string($jolokia_secret)
    }
  }

  if $heap_size {
    $java_opts_final = concat($java_opts, ["-Xmx${heap_size}", "-Xms${heap_size}"])
  } else {
    $java_opts_final = $java_opts
  }

  $service_name = "graphdb-${title}"

  $instance_home_dir = "${graphdb::install_dir}/instances/${title}"
  $instance_data_dir = "${graphdb::data_dir}/${title}"
  $instance_plugins_dir = "${instance_data_dir}/plugins"
  $instance_temp_dir = "${graphdb::tmp_dir}/${title}"
  $instance_conf_dir = "${instance_home_dir}/conf"
  $instance_log_dir = "${graphdb::log_dir}/${title}"

  if $ensure == 'present' {
    File {
      owner => $graphdb::graphdb_user,
      group => $graphdb::graphdb_group,
    }

    $license_file_name = basename($license)
    $licence_file_destination = "${instance_home_dir}/${license_file_name}"

    file { $licence_file_destination:
      ensure => $ensure,
      source => $license,
      mode   => '0555',
      notify => Service[$service_name],
    }

    file { [$instance_home_dir, $instance_data_dir, $instance_plugins_dir, $instance_temp_dir, $instance_conf_dir, $instance_log_dir]:
      ensure => 'directory',
      notify => Service[$service_name],
    }

    if $logback_config {
      file { "${instance_conf_dir}/logback.xml":
        ensure => $ensure,
        source => $logback_config,
      }
    } else {
      file { "${instance_conf_dir}/logback.xml":
        ensure => 'link',
        target => "${graphdb::install_dir}/dist/conf/logback.xml",
      }
    }

    file { "${instance_conf_dir}/tools-logback.xml":
      ensure => 'link',
      target => "${graphdb::install_dir}/dist/conf/tools-logback.xml",
    }

    $default_properties = {
      'graphdb.home.data'      => "${graphdb::data_dir}/${title}",
      'graphdb.home.logs'      => $instance_log_dir,
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

    graphdb_validator { $service_name:
      endpoint  => "http://${::ipaddress}:${http_port}",
      timeout   => $validator_timeout,
      subscribe => Service[$service_name]
    }
  } else {
    file { [$instance_home_dir, $instance_data_dir, $instance_plugins_dir, $instance_temp_dir, $instance_log_dir]:
      ensure  => 'absent',
      force   => true,
      backup  => false,
      recurse => true,
    }
  }

  graphdb::service { $title:
    ensure       => $ensure,
    status       => $status,
    java_opts    => $java_opts_final,
    kill_timeout => $kill_timeout,
    subscribe    => Exec['unpack-graphdb-archive']
  }

}
