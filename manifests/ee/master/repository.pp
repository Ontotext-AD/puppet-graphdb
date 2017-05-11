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
#   default: 0, random port used
#
# [*node_id*]
#   Node id of master instance
#   default: endpoint, same as the master instance endpoint
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
  $replication_port    = 0,
  $node_id             = "${endpoint}/repositories/${repository_id}",
  $timeout             = 60,
) {

  graphdb_repository { $title:
    ensure              => $ensure,
    repository_id       => $repository_id,
    endpoint            => $endpoint,
    repository_template => template($repository_template),
    repository_context  => $repository_context,
    replication_port    => $replication_port,
    node_id             => $node_id,
    timeout             => $timeout,
  }

}
