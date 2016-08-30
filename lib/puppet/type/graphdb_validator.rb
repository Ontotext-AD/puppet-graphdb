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
      raise(ArgumentError, "endpoint should be valid url: #{value}") unless URI(value)
    end
    munge do |value|
      URI(value)
    end
  end

  newparam(:timeout) do
    desc 'The max number of seconds that the validator should wait before giving up and deciding that the GraphDB is not running; default: 60 seconds.'
    defaultto 60
	validate do |value|
		raise(ArgumentError, "Timeout should be valid integer: #{value}") unless Integer(value)
    end
    munge do |value|
      Integer(value)
    end
  end
end
