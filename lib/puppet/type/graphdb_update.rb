require 'uri'

Puppet::Type.newtype(:graphdb_update) do
  @doc = 'Executes update query GraphDB'

  ensurable do
    defaultvalues
    defaultto :present
  end

  newparam(:name, namevar: true) do
    desc 'An arbitrary name used as the identity of the resource.'
  end

  newparam(:repository_id) do
    desc 'The id of the created repository'
    defaultto do
      resource.value(:name)
    end
  end

  newparam(:endpoint) do
    desc 'Sesame endpoint of GraphDB instance'
    validate do |value|
      begin
        URI(value)
      rescue StandardError
        raise(ArgumentError, "endpoint should be valid url: #{value}")
      end
    end
    munge do |value|
      URI(value)
    end
  end

  newparam(:update_query) do
    desc 'The update query you want to execute repository'
    validate do |value|
      value.is_a?(String)
    end
    munge do |value|
      value.gsub('\n', ' ')
    end
  end

  newparam(:exists_query) do
    desc 'The ask query to check whether update has been applied. You can use the following syntax: ask {?s ?p ?o}'
  end

  newparam(:exists_expected_response, boolean: true) do
    desc 'The expected response from exists_query'
    defaultto(true)
  end

  newparam(:timeout) do
    desc 'The max number of seconds that the update process should wait before giving up; default: 60 seconds.'
    defaultto 60
    validate do |value|
      begin
        Integer(value)
      rescue StandardError
        raise(ArgumentError, "timeout should be valid integer: #{value}")
      end
    end
    munge do |value|
      Integer(value)
    end
  end

  # Autorequire the relevant graphdb_repository
  autorequire(:graphdb_repository) do
    repositories = catalog.resources.select do |res|
      next unless res.type == :graphdb_repository
      res if res[:endpoint] == self[:endpoint] && res[:repository_id] == self[:repository_id]
    end
    repositories.collect do |res|
      res[:name]
    end
  end
end
