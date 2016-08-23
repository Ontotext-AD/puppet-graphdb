$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', '..', '..'))
require 'puppet/util/repository_manager'

Puppet::Type.type(:graphdb_repository).provide(:graphdb_repository) do
  desc "A provider for the resource type `graphdb_repository`,
  which creates GraphDB repository from a given template."

  def exists?
    repository_manager.check_repository(resource[:timeout])
  end

  def create
    result = repository_manager.create_repository(resource[:repository_template], resource[:repository_context], resource[:timeout])
    result = exists? if result
    result
  end

  def destroy
    repository_manager.delete_repository(resource[:timeout])
  end

  private

  def repository_manager
    @repository_manager ||= Puppet::Util::RepositoryManager.new(resource[:endpoint], resource[:repository_id])
  end
end
