# == Define: graphdb::ee::worker::repository
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
# For other properties, please, check: {GraphDB documentation}[http://graphdb.ontotext.com/documentation/enterprise/configuring-a-repository.html?highlight=repository#configuration-parameters]
#
# [*repository_id*]
#   Repository ID
#
# [*repository_label*]
#   Repository title
#
# [*default_ns*]
#   Default namespaces for imports(';' delimited)
#
# [*entity_index_size*]
#   Entity index size
#
# [*entity_id_size*]
#   Entity ID bit-size
#
# [*imports*]
#   Imported RDF files(';' delimited)
#
# [*ruleset*]
#   Rule-set
#
# [*storage_folder*]
#   Storage folder
#
# [*enable_context_index*]
#   Use context index
#
# [*enable_predicate_list*]
#   Use predicate indices
#
# [*in_memory_literal_properties*]
#   Cache literal language tags
#
# [*enable_literal_index*]
#   Enable literal index
#
# [*check_for_inconsistencies*]
#   Check for inconsistencies
#
# [*disable_same_as*]
#   Disable OWL sameAs optimisation
#
# [*transaction_mode*]
#   Transaction mode
#
# [*transaction_isolation*]
#   Transaction isolation
#
# [*query_timeout*]
#   Query time-out (seconds)
#
# [*query_limit_results*]
#   Limit query results
#
# [*throw_query_evaluation_exception_on_timeout*]
#   Throw exception on query time-out
#
# [*non_interpretable_predicates*]
#   Non-interpretable predicates
#
# [*read_only*]
#   Read-only
#
define graphdb::ee::worker::repository (
  String $endpoint,
  String $repository_context,
  String $ensure              = $graphdb::ensure,
  String $repository_template = "${module_name}/repository/worker.ttl.erb",
  Integer $timeout            = 60,

  # Here start the repository parameters(note that those are generated from the template that graphdb provides)
  String $repository_id = $title,
  String $repository_label = 'GraphDB EE worker repository',
  String $default_ns = '', # lint:ignore:params_empty_string_assignment
  String $entity_index_size = '200000',
  String $entity_id_size = '32',
  String $imports = '', # lint:ignore:params_empty_string_assignment
  String $ruleset = 'owl-horst-optimized',
  String $storage_folder = 'storage',
  Boolean $enable_context_index = false,
  Boolean $enable_predicate_list = false,
  Boolean $in_memory_literal_properties = false,
  Boolean $enable_literal_index = true,
  Boolean $check_for_inconsistencies = false,
  Boolean $disable_same_as = false,
  String $transaction_mode = 'safe',
  Boolean $transaction_isolation = true,
  String $query_timeout = '0',
  String $query_limit_results = '0',
  Boolean $throw_query_evaluation_exception_on_timeout = false,
  String $non_interpretable_predicates = 'http://www.w3.org/2000/01/rdf-schema#label;http://www.w3.org/1999/02/22-rdf-syntax-ns#type;http://www.ontotext.com/owlim/ces#gazetteerConfig;http://www.ontotext.com/owlim/ces#metadataConfig',
  Boolean $read_only = false,
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
