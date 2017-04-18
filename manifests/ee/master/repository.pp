# == Define: graphdb::ee::master::repository
#
# This define is able to manage GraphDB repository
#
# === Parameters
#
# [*ensure*]
#   Whether the service should exist. Possible values are present and absent.
#
# [*endpoint*]
#   GraphDB endpoint.
#   example: http://localhost:8080
#
# [*repository_context*]
#   The context of the repository.
#   example: http://ontotext.com
#
# [*repository_template*]
#   The template to use for repository creation
#   example: http://ontotext.com
#
# [*replication_port*]
#   Master replication port used for backups
#   default: undef, random port used
#
# [*timeout*]
#   The max number of seconds that the repository create/delete/check process should wait before giving up.
#   default: 60
#
# For other properties, please, check: {GraphDB documentation}[http://graphdb.ontotext.com/documentation/enterprise/configuring-a-repository.html?highlight=repository#configuration-parameters]
#
define graphdb::ee::master::repository (
  $endpoint,
  $repository_context,
  $ensure              = $graphdb::ensure,
  $repository_template = "${module_name}/repository/master.ttl.erb",
  $repository_id       = $title,
  $repository_label    = 'GraphDB EE master repository',
  $timeout             = 60,
  $replication_port    = undef,
) {

  graphdb_repository { $title:
    ensure              => $ensure,
    repository_id       => $repository_id,
    endpoint            => $endpoint,
    repository_template => template($repository_template),
    repository_context  => $repository_context,
    replication_port    => $replication_port,
    timeout             => $timeout,
  }

}
