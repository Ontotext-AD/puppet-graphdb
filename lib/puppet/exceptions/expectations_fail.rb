module Puppet
  module Exceptions
    class ExpectationsFailError < StandardError
      attr_reader :reason
      def initialize(reason)
        @reason = reason
      end
    end
  end
end
