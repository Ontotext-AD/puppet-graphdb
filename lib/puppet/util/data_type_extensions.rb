module Puppet
  module Util
    class DataTypeExtensions
      @@DATA_TYPE_EXT = { '.rdf' => 'rdfxml', '.rdfs' => 'rdfxml', '.owl' => 'rdfxml', '.xml' => 'rdfxml',
                          '.nt' => 'ntriples',
                          '.ttl' => 'turtle',
                          '.n3' => 'n3',
                          '.trix' => 'trix',
                          '.trig' => 'trig',
                          '.brf' => 'binary',
                          '.nq' => 'nquads',
                          '.jsonld' => 'jsonld',
                          '.rj' => 'rdfjson',
                          '.xhtml' => 'rdfa', '.html' => 'rdfa' }.freeze

      def self.[](extension)
        @@DATA_TYPE_EXT[extension]
      end

      def self.key?(extension)
        @@DATA_TYPE_EXT.key?(extension)
      end

      def self.values
        @@DATA_TYPE_EXT.values.uniq
      end
    end
  end
end
