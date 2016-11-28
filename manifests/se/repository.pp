# == Define: graphdb::se::repository
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
# [*timeout*]
#   The max number of seconds that the repository create/delete/check process should wait before giving up.
#   default: 60
#
# For other properties, please, check: {GraphDB documentation}[http://graphdb.ontotext.com/documentation/standard/configuring-a-repository.html?highlight=repository#configuration-parameters]
#
define graphdb::se::repository (
  $endpoint,
  $repository_context,
  $ensure = $graphdb::ensure,
  $repository_template = "${module_name}/repository/se.ttl.erb",
  $timeout = 60,

  # Here start the repository parameters(note that those are generated from the template that graphdb provides)
  # Repository ID
  $repository_id = $title,
  # Repository title
  $repository_label = 'GraphdDB SE repository',
  # Default namespaces for imports(';' delimited)
  $default_ns = '',
  # Entity index size
  $entity_index_size = '200000',
  # Entity ID bit-size
  $entity_id_size = '32',
  # Imported RDF files(';' delimited)
  $imports = '',
  # Rule-set
  $ruleset = 'owl-horst-optimized',
  # Storage folder
  $storage_folder = 'storage',
  # Use context index
  $enable_context_index = false,
  # Use predicate indices
  $enable_predicate_list = false,
  # Cache literal language tags
  $in_memory_literal_properties = false,
  # Enable literal index
  $enable_literal_index = true,
  # Check for inconsistencies
  $check_for_inconsistencies = false,
  # Disable OWL sameAs optimisation
  $disable_same_as = false,
  # Transaction mode
  $transaction_mode = 'safe',
  # Transaction isolation
  $transaction_isolation = true,
  # Query time-out (seconds)
  $query_timeout = '0',
  # Limit query results
  $query_limit_results = '0',
  # Throw exception on query time-out
  $throw_query_evaluation_exception_on_timeout = false,
  # Read-only
  $read_only = false,
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
