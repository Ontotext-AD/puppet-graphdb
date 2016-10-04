$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', '..', '..'))

require 'timeout'
require 'puppet/exceptions/expectations_fail'
require 'puppet/util/http_client'

module Puppet
  module Util
    # Http request manager with expectations checking
    class RequestManager
      def self.perform_http_request(uri, parameters, expectations, timeout)
        start_time = Time.now
        begin
          attempt_http_request_with_expectations(uri, parameters, expectations)
          Puppet.debug("Request marked as passed in #{Time.now - start_time} seconds")
        rescue Timeout::Error, Puppet::Exceptions::ExpectationsFailError => e
          Puppet.debug("Request marked as failed: #{e}")
          if (Time.now - start_time) < timeout
            Puppet.debug('Sleeping 2 seconds before retry...')
            sleep 2
            retry
          else
            raise(Puppet::Error,
                  "Request marked as failed within timeout window of #{timeout}: #{e} #{e.message}")
          end
        end
      end

      def self.attempt_http_request_with_expectations(uri, parameters, expectations)
        Timeout.timeout(Puppet[:configtimeout]) do
          response = Puppet::Util::HttpClient.attempt_http_request(uri, parameters)
          err_message = "Request doesn\'t match expectations\n"
          unless response.nil?
            err_message += "Expected status codes: #{expectations[:codes].join(',')}\n"
            err_message += "Recieved code: #{response.code}\n"
            if expectations.key?(:messages)
              err_message += "Expected messages: #{expectations[:messages].join(',')}\n"
              err_message += "Recieved message: #{response.body}\n"
            end
          end
          raise Puppet::Exceptions::ExpectationsFailError,
                err_message unless matches_expectations?(response, expectations)
        end
      end

      def self.matches_expectations?(response, expectations)
        raise ArgumentError, 'You must pass at least one expected status code' unless expectations.key?(:codes)
        return false if response.nil?

        return false unless matches_status_codes?(response, expectations[:codes])
        return matches_expected_messages?(response, expectations[:messages]) if expectations.key?(:messages)
        true
      end

      def self.matches_status_codes?(response, codes)
        Puppet.debug 'Expected status codes:'
        codes.each do |expected_code|
          Puppet.debug expected_code
        end

        return true if codes.include?(Integer(response.code))

        Puppet.debug "The returned status code doesn't match any of the expected status codes"
        false
      end

      def self.matches_expected_messages?(response, messages)
        Puppet.debug 'Expected response messages:'
        messages.each do |expected_message|
          Puppet.debug expected_message
        end

        messages.each do |expected_message|
          return true unless response.body.match(expected_message).nil?
        end

        Puppet.debug "The returned message doesn't match any of the expected messages"
        false
      end
    end
  end
end
