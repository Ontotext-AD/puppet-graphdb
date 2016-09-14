Puppet::Type.newtype(:graphdb_repository) do
  @doc = 'Creates GraphDB repository'

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

  newparam(:repository_template) do
    desc 'The template of the created repository'
  end

  newparam(:repository_context) do
    desc 'The context of the created repository'
  end

  newparam(:timeout) do
    desc 'The max number of seconds that the validator should wait before giving up
    and deciding that the GraphDB is not running; default: 60 seconds.'
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

  # Autorequire the relevant graphdb_validator
  autorequire(:graphdb_validator) do
    validators = catalog.resources.select do |res|
      next unless res.type == :graphdb_validator
      res if res[:endpoint] == self[:endpoint]
    end
    validators.collect do |res|
      res[:name]
    end
  end
end
