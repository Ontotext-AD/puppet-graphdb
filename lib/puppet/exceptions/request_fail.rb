# frozen_string_literal: true

module Puppet
  module Exceptions
    # Exceptions trown when given request fails
    class RequestFailError < StandardError
      attr_reader :message

      def initialize(message = '')
        @message = message
      end
    end
  end
end
