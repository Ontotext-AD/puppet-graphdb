# frozen_string_literal: true

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', '..', '..'))
require 'puppet/util/master_master_link_manager'
require 'puppet/util/master_worker_link_manager'
require 'puppet/exceptions/request_fail'

Puppet::Type.type(:graphdb_link).provide(:graphdb_link) do
  desc "A provider for the resource type `graphdb_link`,
  which manages master worker links"

  def exists?
    link_manager.check_link
    true
  rescue Puppet::Exceptions::RequestFailError
    false
  end

  def create
    link_manager.create_link
  end

  def destroy
    link_manager.delete_link
  end

  private

  def link_manager
    if !resource[:worker_endpoint].nil? && !resource[:peer_master_endpoint].nil?
      raise Puppet::Error, 'you should provide worker_endpoint or peer_master_endpoint, but not both'
    end

    if !resource[:worker_endpoint].nil? && !resource[:worker_repository_id].nil?
      @link_manager ||= Puppet::Util::MasterWorkerLinkManager.new(resource[:master_endpoint],
                                                                  resource[:master_repository_id],
                                                                  resource[:worker_endpoint],
                                                                  resource[:worker_repository_id],
                                                                  resource[:replication_port])
    elsif !resource[:peer_master_endpoint].nil? && !resource[:peer_master_repository_id].nil?
      node_id = if resource[:peer_master_node_id].nil?
                  resolve_node_id
                else
                  resource[:peer_master_node_id]
                end
      @link_manager ||= Puppet::Util::MasterMasterLinkManager.new(resource[:master_endpoint],
                                                                  resource[:master_repository_id],
                                                                  resource[:peer_master_endpoint],
                                                                  resource[:peer_master_repository_id],
                                                                  node_id)
    else
      raise Puppet::Error, 'please ensure that you provide required worker link details(worker_endpoint and worker_repository_id)
      or required master link details(peer_master_endpoint, peer_master_repository_id and peer_master_node_id)'
    end
  end

  def check_resource_is_matching_master_instance?(resource, port)
    return true if resource.type == :component && !resource[:http_port].nil? && resource[:http_port].to_s == port
    false
  end

  def resolve_node_id
    node_id = nil
    master_endpoint = resource[:peer_master_endpoint]
    master_repository_id = resource[:peer_master_repository_id]
    resource.catalog.resources.each do |resource|
      node_id = resource[:node_id] if check_resource_is_matching_master_repository?(resource, master_endpoint, master_repository_id)
    end
    if node_id.nil?
      raise Puppet::Error, 'fail to resolve node id, please ensure that graphdb_link
        is defined on the same node as master graphdb repository or provide peer_master_node_id'
    end
    node_id
  end

  def check_resource_is_matching_master_repository?(resource, endpoint, repository_id)
    return true if resource.type == :component && (!resource[:repository_id].nil? && !resource[:endpoint].nil?) &&
                   (resource[:repository_id] == repository_id && resource[:endpoint].to_s == endpoint.to_s)

    false
  end
end
