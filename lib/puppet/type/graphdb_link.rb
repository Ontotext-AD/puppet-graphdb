$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', '..', '..'))
require 'uri'

Puppet::Type.newtype(:graphdb_link) do
  @doc = 'Creates link between master and worker'

  ensurable do
    defaultvalues
    defaultto :present
  end

  newparam(:name, namevar: true) do
    desc 'An arbitrary name used as the identity of the resource.'
  end

  newparam(:master_repository_id) do
    desc 'The id of the master repository'
    defaultto do
      resource.value(:name)
    end
  end

  newparam(:master_endpoint) do
    desc 'Sesame endpoint of GraphDB master instance'
    validate do |value|
      raise 'master_endpoint should be valid url' unless URI(value)
    end
    munge do |value|
      URI(value)
    end
  end

  newparam(:worker_repository_id) do
    desc 'The id of the worker repository'
    defaultto do
      resource.value(:name)
    end
  end

  newparam(:worker_endpoint) do
    desc 'Sesame endpoint of GraphDB worker instance'
    validate do |value|
      raise 'worker_endpoint should be valid url' unless URI(value)
    end
    munge do |value|
      URI(value)
    end
  end

  newparam(:replication_port) do
    desc 'The port for replications that master and worker will use; default: 0'
    defaultto 0
    validate do |value|
      raise 'replication_port should be valid integer' unless Integer(value)
    end
    munge do |value|
      Integer(value)
    end
  end

  newparam(:timeout) do
    desc 'The max number of seconds that the validator should wait before giving up; default: 60 seconds'
    defaultto 60
    validate do |value|
      raise 'timeout should be valid integer' unless Integer(value)
    end
    munge do |value|
      Integer(value)
    end
  end

  # Autorequire the relevant graphdb_repository
  autorequire(:graphdb_repository) do
    catalog.resources.select do |res|
      next unless res.type == :graphdb_repository
      res if (res[:endpoint] == self[:master_endpoint] && res[:repository_id] == self[:master_repository_id]) ||
             (res[:endpoint] == self[:worker_endpoint] && res[:repository_id] == self[:worker_repository_id])
    end.collect do |res|
      res[:name]
    end
  end
end
