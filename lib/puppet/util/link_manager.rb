$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', '..', '..'))
require 'puppet/util/request_manager'
require 'json'

module Puppet
  module Util
    class LinkManager
      attr_reader :master_endpoint
      attr_reader :master_repository_id
      attr_reader :worker_endpoint
      attr_reader :worker_repository_id
      attr_reader :jolokia_secret
      attr_reader :replication_port

      def initialize(master_endpoint, master_repository_id, worker_endpoint, worker_repository_id, jolokia_secret, replication_port)
        @master_endpoint = master_endpoint
        @master_repository_id = master_repository_id
        @worker_endpoint = worker_endpoint
        @worker_repository_id = worker_repository_id
        @jolokia_secret = jolokia_secret
        @replication_port = replication_port
      end

      def check_link
        uri = master_endpoint.dup
        uri.path = "/jolokia/read/ReplicationCluster:name=ClusterInfo!/#{master_repository_id}/NodeStatus"
        Puppet::Util::RequestManager.perform_http_request(uri, { method: :get, auth: { user: '', password: jolokia_secret } },
                                                          { messages: [Regexp.escape("#{worker_endpoint}/repositories/#{worker_repository_id}".gsub('/', '\/'))], codes: [200] }, 0)
      end

      def create_link
        uri = master_endpoint.dup
        uri.path = '/jolokia'
        body = {
          'type'      => 'EXEC',
          'mbean'     => "ReplicationCluster:name=ClusterInfo/#{master_repository_id}",
          'operation' => 'addClusterNode',
          'arguments' => ["#{worker_endpoint}/repositories/#{worker_repository_id}", replication_port, 0, true]
        }
        Puppet::Util::RequestManager.perform_http_request(uri, { method: :post, body_data: body.to_json, auth: { user: '', password: jolokia_secret } },
                                                          { messages: [Regexp.escape("#{worker_endpoint}/repositories/#{worker_repository_id}".gsub('/', '\/'))], codes: [200] }, 0)
      end

      def delete_link
        uri = master_endpoint.dup
        uri.path = '/jolokia'
        body = {
          'type'      => 'EXEC',
          'mbean'     => "ReplicationCluster:name=ClusterInfo/#{master_repository_id}",
          'operation' => 'removeClusterNode',
          'arguments' => ["#{worker_endpoint}/repositories/#{worker_repository_id}"]
        }
        Puppet::Util::RequestManager.perform_http_request(uri, { method: :post, body_data: body.to_json, auth: { user: '', password: jolokia_secret } },
                                                          { messages: [Regexp.escape("#{worker_endpoint}/repositories/#{worker_repository_id}".gsub('/', '\/'))], codes: [200] }, 0)
      end

      def list_links
        uri = master_endpoint.dup
        uri.path = "/jolokia/read/ReplicationCluster:name=ClusterInfo!/#{master_repository_id}/NodeStatus"

        request = Puppet::Util::RequestManager.prepare_request(uri, method: :get, auth: { user: '', password: jolokia_secret })
        response = Puppet::Util::RequestManager.attempt_http_request(uri, request)
        resopnse_json = JSON.parse(response.body)
        resopnse_json['value'].map { |link| link.split(' ')[1] }
      end
    end
  end
end
