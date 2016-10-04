require 'spec_helper'
require 'webmock/rspec'
require 'uri'
require 'puppet/util/http_client'
require 'logger'

describe 'HttpClient' do
  describe '#attempt_http_request' do
    BODY_HTTP_METHODS = [:put, :post].freeze
    HTTP_METHODS = [:get, :delete].concat(BODY_HTTP_METHODS).freeze
    FATAL_RESPONSE_CODES = Set.new(%w(400 401 402 403 405 406 407 409 410 411 412 413 414
                                      415 416 417 422 423 424 426 428 431 500 501 502 505 507 511)).freeze

    let(:uri) { 'http://test.com' }

    def call_attempt_http_request
      parameters = { method: method }
      parameters[:params] = params if defined?(params)
      parameters[:body_data] = body_data if defined?(body_data)
      parameters[:body_params] = body_params if defined?(body_params)
      parameters[:content_type] = content_type if defined?(content_type)
      parameters[:accept_type] = accept_type if defined?(accept_type)
      parameters[:auth] = auth if defined?(auth)

      Puppet::Util::HttpClient.attempt_http_request(URI(uri), parameters)
    end

    context 'fail to create request without method' do
      it do
        expect { Puppet::Util::HttpClient.attempt_http_request(URI(uri), {}) }
          .to raise_error(ArgumentError, 'You must pass method in parameters')
      end
    end

    context 'failing with' do
      HTTP_METHODS.each do |method|
        let(:method) { method }
        FATAL_RESPONSE_CODES.each do |fatal_code|
          context "'#{method}' method with fatal response code '#{fatal_code}'" do
            before do
              stub_request(:any, /.*test.com.*/).to_return(status: [fatal_code])
            end

            after do
              WebMock.reset!
            end

            it do
              expect { call_attempt_http_request }.to raise_error(Puppet::Error, /Unrecoverable response recieved/)
            end
          end
        end
        context "'#{method}' method to timeout" do
          before do
            stub_request(:any, /.*test.com.*/).to_timeout
          end

          after do
            WebMock.reset!
          end

          it 'to retrun nil' do
            response = call_attempt_http_request
            expect(response).to be_nil
          end
        end
      end
    end

    context 'successfully with' do
      before do
        stub_request(:any, /.*test.com.*/)
      end

      after do
        WebMock.reset!
      end

      HTTP_METHODS.each do |method|
        context "'#{method}' method" do
          let(:method) { method }

          it do
            call_attempt_http_request
            expect(WebMock).to have_requested(method, uri).once
          end
        end

        context "'#{method}' method with auth" do
          let(:method) { method }
          let(:auth) { { user: 'test_user', password: 'test_password' } }

          it do
            call_attempt_http_request
            expect(WebMock).to have_requested(method,
                                              uri).with(basic_auth: [auth[:user], auth[:password]]).once
          end
        end

        context "'#{method}' method with custom content_type" do
          let(:method) { method }
          let(:content_type) { 'test/test' }

          it do
            call_attempt_http_request
            expect(WebMock).to have_requested(method,
                                              uri).with(headers: { 'Content-Type' => content_type }).once
          end
        end

        context "'#{method}' method with custom accept_type" do
          let(:method) { method }
          let(:accept_type) { 'test/test' }

          it do
            call_attempt_http_request
            expect(WebMock).to have_requested(method,
                                              uri).with(headers: { 'Accept' => accept_type }).once
          end
        end

        context "'#{method}' method with url parameters" do
          let(:method) { method }
          let(:params) { { param1: 'test1', param2: 'test2' } }

          it do
            call_attempt_http_request
            expect(WebMock).to have_requested(method, uri).with(query: params).once
          end
        end

        next unless BODY_HTTP_METHODS.include? method
        context "'#{method}' method with body_data" do
          let(:method) { method }
          let(:body_data) { 'test_data' }

          it do
            call_attempt_http_request
            expect(WebMock).to have_requested(method, uri).with(body: body_data).once
          end
        end

        context "'#{method}' method with body_params" do
          let(:method) { method }
          let(:body_params) { { param1: 'test1', param2: 'test2' } }

          it do
            call_attempt_http_request
            expect(WebMock).to have_requested(method, uri)
              .with(body: body_params.map { |key, value| "#{key}=#{value}" }.join('&')).once
          end
        end
      end
    end
  end
end
