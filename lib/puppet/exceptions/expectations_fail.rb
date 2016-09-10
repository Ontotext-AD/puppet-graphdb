module Puppet
  module Exceptions
    # Exceptions trown when given Expectations aren't met
    class ExpectationsFailError < StandardError
      attr_reader :reason
      def initialize(reason)
        @reason = reason
      end
    end
  end
end
