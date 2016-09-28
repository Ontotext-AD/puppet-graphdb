class graphdb::tool_links {

  File {
    owner => $graphdb::graphdb_user,
    group => $graphdb::graphdb_group,
  }

  $instance_installation_dir = "${graphdb::install_dir}/dist/bin"

  $tool_link_ensure = $graphdb::ensure ? {
    'present'  => 'link',
    default    => $graphdb::ensure,
  }

  file { '/bin/console':
    ensure => $tool_link_ensure,
    target => "${instance_installation_dir}/console",
  }
  file { '/bin/loadrdf':
    ensure => $tool_link_ensure,
    target => "${instance_installation_dir}/loadrdf",
  }
  file { '/bin/migration-wizard':
    ensure => $tool_link_ensure,
    target => "${instance_installation_dir}/migration-wizard",
  }
  file { '/bin/rdfvalidator':
    ensure => $tool_link_ensure,
    target => "${instance_installation_dir}/rdfvalidator",
  }
  file { '/bin/report':
    ensure => $tool_link_ensure,
    target => "${instance_installation_dir}/report",
  }
  file { '/bin/rule-compiler':
    ensure => $tool_link_ensure,
    target => "${instance_installation_dir}/rule-compiler",
  }
  file { '/bin/storage-tool':
    ensure => $tool_link_ensure,
    target => "${instance_installation_dir}/storage-tool",
  }
}
