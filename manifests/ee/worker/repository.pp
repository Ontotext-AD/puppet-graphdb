define graphdb::ee::worker::repository(
  $endpoint,
  $repository_context,
  $ensure = $graphdb::ensure,
  $repository_template = "${module_name}/repository/worker.ttl.erb",

  # Here start the repository parameters(note that those are generated from the template that graphdb provides)
  # Repository ID
  $repository_id = $title,
  # Repository title
  $repository_label = 'GraphDB EE worker repository',
  # Default namespaces for imports(';' delimited)
  $defaultNS = '',
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
  $enablePredicateList = false,
  # Cache literal language tags
  $in_memory_literal_properties = false,
  # Enable literal index
  $enable_literal_index = true,
  # Check for inconsistencies
  $check_for_inconsistencies = false,
  # Disable OWL sameAs optimisation
  $disable_sameAs = false,
  # Transaction mode
  $transaction_mode = 'safe',
  # Transaction isolation
  $transaction_isolation = true,
  # Query time-out (seconds)
  $query_timeout = '0',
  # Limit query results
  $query_limit_results = '0',
  # Throw exception on query time-out
  $throw_QueryEvaluationException_on_timeout = false,
  # Non-interpretable predicates
  $nonInterpretablePredicates = 'http://www.w3.org/2000/01/rdf-schema#label;http://www.w3.org/1999/02/22-rdf-syntax-ns#type;http://www.ontotext.com/owlim/ces#gazetteerConfig;http://www.ontotext.com/owlim/ces#metadataConfig',
  # Read-only
  $read_only = false,
){

  graphdb_repository { $title:
    ensure              => $ensure,
    repository_id       => $repository_id,
    endpoint            => $endpoint,
    repository_template => template($repository_template),
    repository_context  => $repository_context,
  }

}
