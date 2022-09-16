# frozen_string_literal: true

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
      result = repository_manager.define_repository_replication_port(resource[:replication_port])
    end
    unless resource[:node_id].nil?
      result = repository_manager.define_node_id(resource[:node_id])
    end

    result
  end

  def destroy
    repository_manager.delete_repository(resource[:timeout])
  end

  private

  def repository_manager
    @repository_manager ||= Puppet::Util::RepositoryManager.new(resource[:endpoint], resource[:repository_id])
  end

  def check_resource_is_matching_master?(resource, port)
    return true if resource.type == :component && !resource[:http_port].nil? && resource[:http_port].to_s == port

    false
  end
end
