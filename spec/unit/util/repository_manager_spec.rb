# frozen_string_literal: true

require 'spec_helper'
require 'puppet/util/request_manager'
require 'rspec/mocks'

describe 'RepositoryManager' do
  let(:uri) { URI('http://test.com') }
  let(:repository_manager) { Puppet::Util::RepositoryManager.new(uri, 'test') }

  describe '#check_repository' do
    context 'with running repository' do
      it 'should return true' do
        uri.path = '/repositories/test/size'
        allow(Puppet::Util::RequestManager).to receive(:perform_http_request) { true }
        allow(Puppet::Util::RequestManager).to receive(:perform_http_request)
          .with(uri, { method: :get }, { codes: [404] }, 0)
          .and_raise(Puppet::Exceptions::RequestFailError)

        expect { repository_manager.check_repository(60) }.not_to raise_error

        expect(Puppet::Util::RequestManager).to have_received(:perform_http_request).with(
          uri, { method: :get }, { codes: [404] }, 0
        ).once
        expect(Puppet::Util::RequestManager).to have_received(:perform_http_request).with(
          uri,
          { method: :get },
          { messages: ['No workers configured', '\d+'],
            codes: [200, 500] }, 60
        ).once
      end
    end

    context 'with not existing repository' do
      it 'should return false' do
        uri.path = '/repositories/test/size'
        allow(Puppet::Util::RequestManager).to receive(:perform_http_request)
          .with(uri, { method: :get }, { codes: [404] }, 0) { true }

        expect { repository_manager.check_repository(60) }.to raise_error(Puppet::Exceptions::RequestFailError)
        expect(Puppet::Util::RequestManager).to have_received(:perform_http_request).with(
          uri, { method: :get }, { codes: [404] }, 0
        ).once
      end
    end

    context 'with not running repository' do
      it 'should return false' do
        uri.path = '/repositories/test/size'
        allow(Puppet::Util::RequestManager).to receive(:perform_http_request)
          .and_raise(Puppet::Exceptions::RequestFailError)

        expect { repository_manager.check_repository(60) }.to raise_error(Puppet::Exceptions::RequestFailError)
        expect(Puppet::Util::RequestManager).to have_received(:perform_http_request).with(
          uri, { method: :get }, { codes: [404] }, 0
        ).once
        expect(Puppet::Util::RequestManager).to have_received(:perform_http_request).with(
          uri,
          { method: :get },
          { messages: ['No workers configured', '\d+'],
            codes: [200, 500] }, 60
        ).once
      end
    end
  end

  describe '#create_repository' do
    context 'with successfully created repository' do
      it 'should return true' do
        allow(Puppet::Util::RequestManager).to receive(:perform_http_request) { true }

        expect { repository_manager.create_repository('test', 'http://test.com', 60) }.not_to raise_error
        uri.path = '/repositories/SYSTEM/rdf-graphs/service'
        expect(Puppet::Util::RequestManager).to have_received(:perform_http_request).with(
          uri, { method: :post,
                 params: { 'graph' => 'http://test.com' },
                 body_data: 'test',
                 content_type: 'application/x-turtle' },
          { codes: [204] }, 60
        ).once
      end
    end

    context 'with unsuccessfully created repository' do
      it 'should return false' do
        allow(Puppet::Util::RequestManager).to receive(:perform_http_request)
          .and_raise(Puppet::Exceptions::RequestFailError)

        expect { repository_manager.create_repository('test', 'http://test.com', 60) }
          .to raise_error(Puppet::Exceptions::RequestFailError)
      end
    end
  end

  describe '#delete_repository' do
    context 'with successfully deleted repository' do
      it 'should return true' do
        allow(Puppet::Util::RequestManager).to receive(:perform_http_request) { true }

        expect { repository_manager.delete_repository(60) }.not_to raise_error
        uri.path = '/repositories/test'
        expect(Puppet::Util::RequestManager).to have_received(:perform_http_request).with(
          uri,
          { method: :delete, content_type: 'application/x-turtle' },
          { codes: [204] },
          60
        ).once
      end
    end

    context 'with unsuccessfully deleted repository' do
      it 'should return false' do
        allow(Puppet::Util::RequestManager).to receive(:perform_http_request)
          .and_raise(Puppet::Exceptions::RequestFailError)

        expect { repository_manager.delete_repository(60) }.to raise_error(Puppet::Exceptions::RequestFailError)
      end
    end
  end

  describe '#ask' do
    context 'with successful ask query' do
      it 'should return true' do
        allow(Puppet::Util::RequestManager).to receive(:perform_http_request) { true }

        result = repository_manager.ask('test_query', 'test_expected_response', 60)

        expect(result).to be true
        uri.path = '/repositories/test'
        expect(Puppet::Util::RequestManager).to have_received(:perform_http_request).with(
          uri, { method: :get,
                 params: { 'query' => 'test_query' },
                 content_type: 'application/x-www-form-urlencoded',
                 accept_type: 'text/boolean' },
          { messages: ['test_expected_response'], codes: [200] },
          60
        ).once
      end
    end

    context 'with unsuccessful ask query' do
      it 'should return false' do
        allow(Puppet::Util::RequestManager).to receive(:perform_http_request) { false }

        result = repository_manager.ask('test_query', 'test_expected_response', 60)
        expect(result).to be false
      end
    end
  end

  describe '#update_query' do
    context 'with successful update query' do
      it 'should return true' do
        allow(Puppet::Util::RequestManager).to receive(:perform_http_request) { true }

        result = repository_manager.update_query('test_query', 60)

        expect(result).to be true
        uri.path = '/repositories/test/statements'
        expect(Puppet::Util::RequestManager).to have_received(:perform_http_request).with(
          uri,
          { method: :post,
            body_params: { 'update' => 'test_query' },
            content_type: 'application/x-www-form-urlencoded' },
          { codes: [204] },
          60
        ).once
      end
    end

    context 'with unsuccessful update query' do
      it 'should return false' do
        allow(Puppet::Util::RequestManager).to receive(:perform_http_request) { false }

        result = repository_manager.update_query('test_query', 60)
        expect(result).to be false
      end
    end
  end

  describe '#load_data' do
    context 'with successfully loaded data' do
      it 'should return true' do
        allow(Puppet::Util::RequestManager).to receive(:perform_http_request) { true }
        uri.path = '/repositories/test/statements'

        result = repository_manager.load_data('test_data', 'rdfxml', 'test_data_context', true, 60)

        expect(result).to be true
        expect(Puppet::Util::RequestManager).to have_received(:perform_http_request).with(
          uri,
          { method: :put,
            params: { 'context' => 'test_data_context' },
            body_data: 'test_data',
            content_type: 'application/rdf+xml; charset=utf-8' },
          { codes: [204] },
          60
        ).once

        result = repository_manager.load_data('test_data', 'rdfxml', 'test_data_context', false, 60)
        expect(result).to be true
        expect(Puppet::Util::RequestManager).to have_received(:perform_http_request).with(
          uri,
          { method: :post,
            params: { 'context' => 'test_data_context' },
            body_data: 'test_data',
            content_type: 'application/rdf+xml; charset=utf-8' },
          { codes: [204] },
          60
        ).once
      end
    end

    context 'with unknown data format' do
      it do
        expect { repository_manager.load_data('test_data', 'test', 'test_data_context', true, 60) }
          .to raise_error(ArgumentError, 'Unknown data format [test], please check')
      end
    end

    context 'with unsuccessfully loaded data' do
      it 'should return false' do
        allow(Puppet::Util::RequestManager).to receive(:perform_http_request) { false }

        result = repository_manager.load_data('test_data', 'rdfxml', 'test_data_context', true, 60)
        expect(result).to be false
      end
    end
  end
end
