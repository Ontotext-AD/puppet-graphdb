$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', '..', '..'))
require 'puppet/util/request_manager'
require 'json'

module Puppet
  module Util
    # GraphDB master worker link manager
    class MasterWorkerLinkManager
      attr_reader :master_endpoint
      attr_reader :master_repository_id
      attr_reader :worker_endpoint
      attr_reader :worker_repository_id
      attr_reader :jolokia_secret
      attr_reader :replication_port

      def initialize(master_endpoint, master_repository_id, worker_endpoint, worker_repository_id, jolokia_secret,
                     replication_port)
        @master_endpoint = master_endpoint
        @master_repository_id = master_repository_id
        @worker_endpoint = worker_endpoint
        @worker_repository_id = worker_repository_id
        @jolokia_secret = jolokia_secret
        @replication_port = replication_port
      end

      def check_link
        Puppet.debug "Check link between master_endpoint/repositories/master_repository_id
          and worker_endpoint/repositories/worker_repository_id"

        uri = master_endpoint.dup
        uri.path = "/jolokia/read/ReplicationCluster:name=ClusterInfo!/#{master_repository_id}/NodeStatus"
        expected_massage = Regexp.escape("#{worker_endpoint}/repositories/#{worker_repository_id}".gsub('/', '\/'))

        Puppet::Util::RequestManager.perform_http_request(uri,
                                                          { method: :get,
                                                            auth: { user: '', password: jolokia_secret } },
                                                          { messages: [expected_massage],
                                                            codes: [200] }, 0)
      end

      def create_link
        Puppet.debug "Creating link between master_endpoint/repositories/master_repository_id
          and worker_endpoint/repositories/worker_repository_id"

        uri = master_endpoint.dup
        uri.path = '/jolokia'
        body = {
          'type'      => 'EXEC',
          'mbean'     => "ReplicationCluster:name=ClusterInfo/#{master_repository_id}",
          'operation' => 'addClusterNode',
          'arguments' => ["#{worker_endpoint}/repositories/#{worker_repository_id}", replication_port, 0, true]
        }
        expected_massage = Regexp.escape("#{worker_endpoint}/repositories/#{worker_repository_id}".gsub('/', '\/'))

        Puppet::Util::RequestManager.perform_http_request(uri,
                                                          { method: :post,
                                                            body_data: body.to_json,
                                                            auth: { user: '', password: jolokia_secret } },
                                                          { messages: [expected_massage],
                                                            codes: [200] }, 0)
      end

      def delete_link
        Puppet.debug "Deleting link between master_endpoint/repositories/master_repository_id
        and worker_endpoint/repositories/worker_repository_id"

        uri = master_endpoint.dup
        uri.path = '/jolokia'
        body = {
          'type'      => 'EXEC',
          'mbean'     => "ReplicationCluster:name=ClusterInfo/#{master_repository_id}",
          'operation' => 'removeClusterNode',
          'arguments' => ["#{worker_endpoint}/repositories/#{worker_repository_id}"]
        }
        expected_massage = Regexp.escape("#{worker_endpoint}/repositories/#{worker_repository_id}".gsub('/', '\/'))

        Puppet::Util::RequestManager.perform_http_request(uri,
                                                          { method: :post,
                                                            body_data: body.to_json,
                                                            auth: { user: '', password: jolokia_secret } },
                                                          { messages: [expected_massage],
                                                            codes: [200] }, 0)
      end
    end
  end
end
