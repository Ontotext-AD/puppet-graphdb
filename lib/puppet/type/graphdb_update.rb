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
      raise(ArgumentError, "endpoint should be valid url: #{value}") unless URI(value)
    end
    munge do |value|
      URI(value)
    end
  end

  newparam(:update_query) do
    desc 'The update query you want to execute repository'
    munge do |value|
      if value.is_a?(String)
        value.gsub!(/[\n]+/, ' ')
      else
        value
      end
    end
  end

  newparam(:exists_query) do
    desc 'The ask query to check whether update has been applied. You can use the following syntax: ask {?s ?p ?o}'
  end

  newparam(:exists_expected_response) do
    desc 'The expected response from exists_query'
    defaultto(:true)
    newvalues(:true, :false)
  end

  newparam(:timeout) do
    desc 'The max number of seconds that the validator should wait before giving up; default: 60 seconds.'
    defaultto 60
    validate do |value|
		raise(ArgumentError, "Timeout should be valid integer: #{value}") unless Integer(value)
    end
    munge do |value|
      Integer(value)
    end
  end

  # Autorequire the relevant graphdb_repository
  autorequire(:graphdb_repository) do
    catalog.resources.select do |res|
      next unless res.type == :graphdb_repository
      res if res[:endpoint] == self[:endpoint] && res[:repository_id] == self[:repository_id]
    end.collect do |res|
      res[:name]
    end
  end
end
