$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', '..', '..'))
require 'puppet/util/repository_manager'
require 'puppet/exceptions/request_fail'

Puppet::Type.type(:graphdb_repository).provide(:graphdb_repository) do
  desc "A provider for the resource type `graphdb_repository`,
  which creates GraphDB repository from a given template."

  def exists?
    repository_manager.check_repository(resource[:timeout])
    true
  rescue Puppet::Exceptions::RequestFailError
    false
  end

  def create
    repository_manager.create_repository(
      resource[:repository_template],
      resource[:repository_context],
      resource[:timeout]
    )

    result = repository_manager.repository_up?(0)
    unless resource[:replication_port].nil?
      result = repository_manager.set_repository_replication_port(resource[:replication_port])
    end

    result
  end

  def destroy
    repository_manager.delete_repository(resource[:timeout])
  end

  private

  def repository_manager
    @repository_manager ||= Puppet::Util::RepositoryManager.new(resource[:endpoint], resource[:repository_id], resolve_julokia_secret)
   end

  def resolve_julokia_secret
    port = resource[:endpoint].port.to_s
    julokia_secret = nil
    resource.catalog.resources.each do |resource|
      julokia_secret = resource[:jolokia_secret] if check_resource_is_matching_master?(resource, port)
    end
    if julokia_secret.nil? && !resource[:replication_port].nil?
      raise Puppet::Error, 'fail to resolve julokia secret, please ensure that graphdb_repository
	        					is defined on the same node as master graphdb instance'
    end
   end

  def check_resource_is_matching_master?(resource, port)
    return true if resource.type == :component && !resource[:http_port].nil? && resource[:http_port].to_s == port && !resource[:jolokia_secret].nil?
    false
   end
end
