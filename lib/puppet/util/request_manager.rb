require 'net/http'
require 'timeout'
require 'puppet/exceptions/expectations_fail'

module Puppet
  module Util
    class RequestManager
      # TODO: Maybe we should include more like: 500
      FATAL_RESPONSE_CODES = Set.new(%w(400 401 402 403 405 406 407 409 410 411 412 413 414 415 416 417 422 423 424 426 428 431 501 502 505 507 511)).freeze

      VERB_MAP = {
        get: Net::HTTP::Get,
        post: Net::HTTP::Post,
        put: Net::HTTP::Put,
        delete: Net::HTTP::Delete
      }.freeze

      def self.perform_http_request(uri, parameters, expectations, timeout)
        request = prepare_request(uri, parameters)

        start_time = Time.now
        begin
          attempt_http_request_with_expectations(uri, request, expectations)
          Puppet.debug("Request marked as passed in #{Time.now - start_time} seconds")
          return true
        rescue Timeout::Error, Puppet::Exceptions::ExpectationsFailError => e
          Puppet.debug("Request marked as failed: #{e.reason}")
          if (Time.now - start_time) < timeout
            Puppet.debug('Sleeping 2 seconds before retry...')
            sleep 2
            retry
          end
        end

        Puppet.debug("Request marked as failed within timeout window of #{timeout} seconds, giving up")
        false
      end

      private

      def self.prepare_request(uri, parameters)
        raise ArgumentError, 'You must pass method in request_parameters' unless parameters.key?(:method)
        method = parameters[:method]

        uri.query = URI.encode_www_form(parameters[:params]) if parameters.key?(:params)
        request = VERB_MAP[method].new(uri.request_uri)

        if method == :put || method == :post
          request.body = parameters[:body_data] if parameters.key?(:body_data)
          request.set_form_data(parameters[:body_params]) if parameters.key?(:body_params)
        end

        request.content_type = parameters[:content_type] if parameters.key?(:content_type)
        request['Accept'] = parameters[:accept_type] if parameters.key?(:accept_type)

        if parameters.key?(:auth)
          auth = parameters[:auth]
          raise ArgumentError, 'You must pass user with auth parameter' unless auth.key?(:user)
          raise ArgumentError, 'You must pass password with auth parameter' unless auth.key?(:password)

          request.basic_auth(auth[:user], auth[:password])
        end

        Puppet.debug('Final request:')
        Puppet.debug("Uri: #{uri}")
        Puppet.debug("Method: #{request.method}")
        Puppet.debug('Headers: ')
        request.each_header { |key, value| Puppet.debug("#{key} = #{value}") }
        Puppet.debug("Body: #{request.body}") unless request.body.nil?

        request
      end

      def self.attempt_http_request_with_expectations(uri, request, expectations)
        Timeout.timeout(Puppet[:configtimeout]) do
          response = attempt_http_request(uri, request)
          raise Puppet::Exceptions::ExpectationsFailError, 'Request doesn\'t match expectations' unless matches_expectations(response, expectations)
        end
      end

      def self.attempt_http_request(uri, request)
        http = Net::HTTP.new(uri.host, uri.port)
        http.open_timeout = 60 # in seconds
        http.read_timeout = 60 # in seconds

        begin
          response = http.request(request)
        rescue Exception => e
          Puppet.debug "Error ocured while making request: #{e}"
          return nil
        end

        if FATAL_RESPONSE_CODES.include?(response.code)
          raise Puppet::Error, "Unrecoverable response recieved #{response.message} with code [#{response.code}] and body [#{response.body}]"
        end

        Puppet.debug('Recieved response:')
        Puppet.debug("Code: #{response.code}")
        Puppet.debug("Body: #{response.body}") unless response.body.nil?

        response
      end

      def self.matches_expectations(response, expectations)
        raise ArgumentError, 'You must pass at least one expected status code' unless expectations.key?(:codes)
        return false if response.nil?

        Puppet.debug 'Expected status codes:'
        for expected_code in expectations[:codes]
          Puppet.debug expected_code
        end

        unless expectations[:codes].include?(Integer(response.code))
          Puppet.debug "The returned status code doesn't match any of the expected status codes"
          return false
        end

        if expectations.key?(:messages)
          Puppet.debug 'Expected response messages:'
          for expected_message in expectations[:messages]
            Puppet.debug expected_message
          end

          for expected_message in expectations[:messages]
            if response.body.match(expected_message).nil? == false
              Puppet.debug "Response body matches: #{expected_message}"
              return true
            end
          end

          Puppet.debug "The returned message doesn't match any of the expected messages"
          false
        else
          return true
        end
      end
    end
  end
end
