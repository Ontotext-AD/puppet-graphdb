define graphdb::ee::master::repository (
  $endpoint,
  $repository_context,
  $ensure = $graphdb::ensure,
  $repository_template = "${module_name}/repository/master.ttl.erb",
  $repository_id = $title,
  $repository_label = 'GraphDB EE master repository',
  $timeout = 60,
) {

  graphdb_repository { $title:
    ensure              => $ensure,
    repository_id       => $repository_id,
    endpoint            => $endpoint,
    repository_template => template($repository_template),
    repository_context  => $repository_context,
    timeout             => $timeout,
  }

}
