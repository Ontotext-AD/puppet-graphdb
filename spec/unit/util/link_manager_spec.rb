require 'spec_helper'
require 'puppet/util/link_manager'
require 'puppet/util/request_manager'
require 'rspec/mocks'

describe 'LinkManager' do
  let(:uri_master) { URI('http://test.com/master') }
  let(:uri_worker) { URI('http://test.com/worker') }
  let(:master_repository) { 'master' }
  let(:worker_repository) { 'worker' }
  let(:jolokia_secret) { 'secret' }
  let(:replication_port) { 9000 }

  let(:link_manager) do
    Puppet::Util::LinkManager.new(uri_master, master_repository, uri_worker, worker_repository, jolokia_secret,
                                  replication_port)
  end

  describe '#check_link' do
    context 'with successfully created link' do
      it 'should return true' do
        allow(Puppet::Util::RequestManager).to receive(:perform_http_request) { true }

        expect(link_manager.check_link).to be true
        uri_master.path = "/jolokia/read/ReplicationCluster:name=ClusterInfo!/#{master_repository}/NodeStatus"
        expect(Puppet::Util::RequestManager).to have_received(:perform_http_request).with(
          uri_master,
          { method: :get,
            auth: { user: '', password: jolokia_secret } },
          { messages: [Regexp.escape("#{uri_worker}/repositories/#{worker_repository}".gsub('/', '\/'))],
            codes: [200] }, 0
        ).once
      end
    end

    context 'with unsuccessfully created repository' do
      it 'should return false' do
        allow(Puppet::Util::RequestManager).to receive(:perform_http_request) { false }

        result = link_manager.check_link
        expect(result).to be false
      end
    end
  end

  describe '#create_link' do
    context 'with successfully created link' do
      it 'should return true' do
        allow(Puppet::Util::RequestManager).to receive(:perform_http_request) { true }

        result = link_manager.create_link

        expect(result).to be true
        uri_master.path = '/jolokia'

        body = {
          'type' => 'EXEC',
          'mbean'     => "ReplicationCluster:name=ClusterInfo/#{master_repository}",
          'operation' => 'addClusterNode',
          'arguments' => ["#{uri_worker}/repositories/#{worker_repository}", replication_port, 0, true]
        }.to_json

        expect(Puppet::Util::RequestManager).to have_received(:perform_http_request).with(
          uri_master,
          { method: :post, body_data: body,
            auth: { user: '', password: jolokia_secret } },
          { messages: [Regexp.escape("#{uri_worker}/repositories/#{worker_repository}".gsub('/', '\/'))],
            codes: [200] }, 0
        ).once
      end
    end

    context 'with unsuccessfully created link' do
      it 'should return false' do
        allow(Puppet::Util::RequestManager).to receive(:perform_http_request) { false }

        result = link_manager.create_link
        expect(result).to be false
      end
    end
  end

  describe '#delete_link' do
    context 'with successfully deleted link' do
      it 'should return true' do
        allow(Puppet::Util::RequestManager).to receive(:perform_http_request) { true }

        result = link_manager.delete_link

        expect(result).to be true
        uri_master.path = '/jolokia'

        body = {
          'type' => 'EXEC',
          'mbean'     => "ReplicationCluster:name=ClusterInfo/#{master_repository}",
          'operation' => 'removeClusterNode',
          'arguments' => ["#{uri_worker}/repositories/#{worker_repository}"]
        }.to_json

        expect(Puppet::Util::RequestManager).to have_received(:perform_http_request).with(
          uri_master,
          { method: :post, body_data: body,
            auth: { user: '', password: jolokia_secret } },
          { messages: [Regexp.escape("#{uri_worker}/repositories/#{worker_repository}".gsub('/', '\/'))],
            codes: [200] }, 0
        ).once
      end
    end

    context 'with unsuccessfully deketed link' do
      it 'should return false' do
        allow(Puppet::Util::RequestManager).to receive(:perform_http_request) { false }

        result = link_manager.delete_link
        expect(result).to be false
      end
    end
  end
end
