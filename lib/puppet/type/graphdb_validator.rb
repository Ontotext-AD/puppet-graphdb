Puppet::Type.newtype(:graphdb_validator) do
  @doc = 'Checks whether GraphDB instance is running'

  ensurable do
    defaultvalues
    defaultto :present
  end

  newparam(:name, namevar: true) do
    desc 'An arbitrary name used as the identity of the resource.'
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

  # Autorequire the relevant service if available
  autorequire(:service) do
    repositories = catalog.resources.select do |res|
      next unless res.type == :service
      res if res[:name] == self[:name]
    end
    repositories.collect do |res|
      res[:name]
    end
  end
end
