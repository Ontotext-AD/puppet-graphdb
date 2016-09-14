require 'net/http'

module Puppet
  module Util
    # Http client
    class HttpClient
      # TODO: Maybe we should include more like: 500
      FATAL_RESPONSE_CODES = Set.new(%w(400 401 402 403 405 406 407 409 410 411 412 413 414
                                        415 416 417 422 423 424 426 428 431 501 502 505 507 511)).freeze

      VERB_MAP = {
        get: Net::HTTP::Get,
        post: Net::HTTP::Post,
        put: Net::HTTP::Put,
        delete: Net::HTTP::Delete
      }.freeze

      def self.attempt_http_request(uri, parameters)
        request = create_request(uri, parameters)
        perform_http_request(uri, request)
      end

      def self.create_request(uri, parameters)
        method = resolve_method(parameters)
        uri.query = URI.encode_www_form(parameters[:params]) if parameters.key?(:params)
        request = VERB_MAP[method].new(uri.request_uri)

        prepare_request(request, parameters)
        log_request(uri, request)
        request
      end

      def self.prepare_request(request, parameters)
        request.body = parameters[:body_data] if parameters.key?(:body_data)
        request.set_form_data(parameters[:body_params]) if parameters.key?(:body_params)
        request.content_type = parameters[:content_type] if parameters.key?(:content_type)
        request['Accept'] = parameters[:accept_type] if parameters.key?(:accept_type)

        set_auth(request, parameters) if parameters.key?(:auth)
      end

      def self.resolve_method(parameters)
        raise ArgumentError, 'You must pass method in parameters' unless parameters.key?(:method)
        parameters[:method]
      end

      def self.log_request(uri, request)
        Puppet.debug('Final request:')
        Puppet.debug("Uri: #{uri}")
        Puppet.debug("Method: #{request.method}")
        Puppet.debug('Headers: ')
        request.each_header { |key, value| Puppet.debug("#{key} = #{value}") }
        Puppet.debug("Body: #{request.body}") unless request.body.nil?
      end

      def self.set_auth(request, parameters)
        auth = parameters[:auth]
        raise ArgumentError, 'You must pass user with auth parameter' unless auth.key?(:user)
        raise ArgumentError, 'You must pass password with auth parameter' unless auth.key?(:password)

        request.basic_auth(auth[:user], auth[:password])
      end

      def self.perform_http_request(uri, request)
        http = Net::HTTP.new(uri.host, uri.port)
        http.open_timeout = 60 # in seconds
        http.read_timeout = 60 # in seconds

        begin
          response = http.request(request)
        rescue StandardError => e
          Puppet.debug "Request failed: #{e}"
          return nil
        end

        if FATAL_RESPONSE_CODES.include?(response.code)
          raise Puppet::Error, "Unrecoverable response recieved [#{response.code}]"
        end

        Puppet.debug('Recieved response:')
        Puppet.debug("Code: #{response.code}")
        Puppet.debug("Body: #{response.body}") unless response.body.nil?

        response
      end
    end
  end
end
