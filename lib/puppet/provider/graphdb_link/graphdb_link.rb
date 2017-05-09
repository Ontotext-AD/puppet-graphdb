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
    @link_manager ||= if !resource[:worker_endpoint].nil?
                        Puppet::Util::MasterWorkerLinkManager.new(resource[:master_endpoint],
                                                                  resource[:master_repository_id],
                                                                  resource[:worker_endpoint],
                                                                  resource[:worker_repository_id],
                                                                  resolve_julokia_secret,
                                                                  resource[:replication_port])
                      elsif !resource[:peer_master_endpoint].nil?
                        Puppet::Util::MasterMasterLinkManager.new(resource[:master_endpoint],
                                                                  resource[:master_repository_id],
                                                                  resource[:peer_master_endpoint],
                                                                  resource[:peer_master_repository_id],
                                                                  resolve_julokia_secret,
                                                                  resource[:peer_master_node_id])
                      else
                        raise Puppet::Error, 'please ensure that you provide required worker link details(worker_endpoint and worker_repository_id)
                          or required master link details(peer_master_endpoint, peer_master_repository_id)'
                      end
  end

  def resolve_julokia_secret
    port = resource[:master_endpoint].port.to_s
    julokia_secret = nil
    resource.catalog.resources.each do |resource|
      julokia_secret = resource[:jolokia_secret] if check_resource_is_matching_master?(resource, port)
    end
    if julokia_secret.nil?
      raise Puppet::Error, 'fail to resolve julokia secret, please ensure that graphdb_link
      	is defined on the same node as master graphdb instance'
    end
  end

  def check_resource_is_matching_master?(resource, port)
    return true if resource.type == :component && !resource[:http_port].nil? && resource[:http_port].to_s == port && !resource[:jolokia_secret].nil?
    false
  end
end
