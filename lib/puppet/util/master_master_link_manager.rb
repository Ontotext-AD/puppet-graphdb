# frozen_string_literal: true

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', '..', '..'))
require 'puppet/util/request_manager'
require 'json'

module Puppet
  module Util
    # GraphDB master master link manager
    class MasterMasterLinkManager
      attr_reader :master_endpoint
      attr_reader :master_repository_id
      attr_reader :peer_master_endpoint
      attr_reader :peer_master_repository_id
      attr_reader :peer_master_node_id

      def initialize(master_endpoint, master_repository_id, peer_master_endpoint, peer_master_repository_id,
                     peer_master_node_id)
        @master_endpoint = master_endpoint
        @master_repository_id = master_repository_id
        @peer_master_endpoint = peer_master_endpoint
        @peer_master_repository_id = peer_master_repository_id
        @peer_master_node_id = peer_master_node_id
      end

      def check_link
        Puppet.debug "Check link between #{master_endpoint}/repositories/#{master_repository_id}
        	and #{peer_master_endpoint}/repositories/#{peer_master_repository_id}"

        uri = master_endpoint.dup
        uri.path = "/jolokia/read/ReplicationCluster:name=ClusterInfo!/#{master_repository_id}/SyncPeers"
        expected_massage = Regexp.escape("#{peer_master_endpoint}/repositories/#{peer_master_repository_id}".gsub('/', '\/'))

        Puppet::Util::RequestManager.perform_http_request(uri,
                                                          { method: :get },
                                                          { messages: [expected_massage],
                                                            codes: [200] }, 0)
      end

      def create_link
        Puppet.debug "Creating link between #{master_endpoint}/repositories/#{master_repository_id}
        	and #{peer_master_endpoint}/repositories/#{peer_master_repository_id}"
        uri = master_endpoint.dup
        uri.path = '/jolokia'
        body = {
          'type' => 'EXEC',
          'mbean' => "ReplicationCluster:name=ClusterInfo/#{master_repository_id}",
          'operation' => 'addSyncPeer',
          'arguments' => [peer_master_node_id, "#{peer_master_endpoint}/repositories/#{peer_master_repository_id}"]
        }
        expected_massage = Regexp.escape("#{peer_master_endpoint}/repositories/#{peer_master_repository_id}".gsub('/', '\/'))

        Puppet::Util::RequestManager.perform_http_request(uri,
                                                          { method: :post,
                                                            content_type: 'application/json',
                                                            body_data: body.to_json },
                                                          { messages: [expected_massage],
                                                            codes: [200] }, 0)
      end

      def delete_link
        Puppet.debug "Deleting link between #{master_endpoint}/repositories/#{master_repository_id}
        	and #{peer_master_endpoint}/repositories/#{peer_master_repository_id}"

        uri = master_endpoint.dup
        uri.path = '/jolokia'
        expected_massage = Regexp.escape(peer_master_node_id.gsub('/', '\/'))

        body = {
          'type' => 'EXEC',
          'mbean' => "ReplicationCluster:name=ClusterInfo/#{master_repository_id}",
          'operation' => 'removeSyncPeer',
          'arguments' => [peer_master_node_id]
        }

        Puppet::Util::RequestManager.perform_http_request(uri,
                                                          { method: :post,
                                                            content_type: 'application/json',
                                                            body_data: body.to_json },
                                                          { messages: [expected_massage],
                                                            codes: [200] }, 0)
      end
    end
  end
end
