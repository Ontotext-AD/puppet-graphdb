require 'spec_helper'
require 'puppet/util/master_master_link_manager'
require 'puppet/util/request_manager'
require 'rspec/mocks'

describe 'MasterMasterLinkManager' do
  let(:uri_master) { URI('http://test.com/master') }
  let(:uri_peer_master) { URI('http://test.com/peer_master') }
  let(:master_repository) { 'master' }
  let(:peer_master_repository) { 'master' }
  let(:peer_master_node_id) { 'peer_master' }

  let(:link_manager) do
    Puppet::Util::MasterMasterLinkManager.new(uri_master, master_repository, uri_peer_master, peer_master_repository,
                                              peer_master_node_id)
  end

  describe '#check_link' do
    context 'with successfully created link' do
      it 'should return true' do
        allow(Puppet::Util::RequestManager).to receive(:perform_http_request) { true }

        expect(link_manager.check_link).to be true
        uri_master.path = "/jolokia/read/ReplicationCluster:name=ClusterInfo!/#{master_repository}/SyncPeers"
        expect(Puppet::Util::RequestManager).to have_received(:perform_http_request).with(
          uri_master,
          { method: :get },
          { messages: [Regexp.escape("#{uri_peer_master}/repositories/#{peer_master_repository}".gsub('/', '\/'))],
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
          'operation' => 'addSyncPeer',
          'arguments' => [peer_master_node_id, "#{uri_peer_master}/repositories/#{peer_master_repository}"]
        }.to_json

        expect(Puppet::Util::RequestManager).to have_received(:perform_http_request).with(
          uri_master,
          { method: :post, body_data: body },
          { messages: [Regexp.escape("#{uri_peer_master}/repositories/#{peer_master_repository}".gsub('/', '\/'))],
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
          'operation' => 'removeSyncPeer',
          'arguments' => [peer_master_node_id]
        }.to_json

        expect(Puppet::Util::RequestManager).to have_received(:perform_http_request).with(
          uri_master,
          { method: :post, body_data: body },
          { messages: [peer_master_node_id],
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
