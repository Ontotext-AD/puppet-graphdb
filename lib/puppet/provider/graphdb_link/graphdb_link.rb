$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', '..', '..'))
require 'puppet/util/link_manager'

Puppet::Type.type(:graphdb_link).provide(:graphdb_link) do
  desc "A provider for the resource type `graphdb_link`,
  which manages master worker links"

  def exists?
    Puppet.debug 'Check worker is already connected with master'
    link_manager.check_link
  end

  def create
    Puppet.debug "Creating link between #{resource[:master_endpoint]}/repositories/#{resource[:master_repository_id]}
	 								and #{resource[:worker_endpoint]}/repositories/#{resource[:worker_repository_id]}"
    link_manager.create_link
  end

  def destroy
    Puppet.debug "Deleting link between #{resource[:master_endpoint]}/repositories/#{resource[:master_repository_id]}
									and #{resource[:worker_endpoint]}/repositories/#{resource[:worker_repository_id]}"
    link_manager.delete_link
  end

private

  def link_manager
    @link_manager ||= Puppet::Util::LinkManager.new(resource[:master_endpoint],
                                                    resource[:master_repository_id],
                                                    resource[:worker_endpoint],
                                                    resource[:worker_repository_id],
                                                    resolve_julokia_secret,
                                                    resource[:replication_port])
  end

  def resolve_julokia_secret
    port = resource[:master_endpoint].port.to_s
    julokia_secret = nil
    resource.catalog.resources.each do |resource|
      julokia_secret = resource[:jolokia_secret] if check_resource_is_matching_master?(resource, port)
    end
    raise Puppet::Error, 'fail to resolve julokia secret, please ensure that graphdb_link
										is defined on the same node as master graphdb instance' if julokia_secret.nil?
  end

  def check_resource_is_matching_master?(resource, port)
    return true if resource.type == :component && resource[:http_port] == port && !resource[:jolokia_secret].nil?
    false
  end
end
