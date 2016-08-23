$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', '..', '..'))
require 'puppet/util/request_manager'

Puppet::Type.type(:graphdb_validator).provide(:graphdb_validator) do
  desc "A provider for the resource type `graphdb_validator`,
		which checks whether GraphDB instance is running"

  def exists?
    uri = resource[:endpoint]
    uri.path = '/protocol'
    Puppet::Util::RequestManager.perform_http_request(uri, { method: :get }, { codes: [200] }, resource[:timeout])
  end

  def create
    # If `#create` is called, that means that `#exists?` returned false, which
    # means that the connection could not be established... so we need to
    # cause a failure here.
    raise Puppet::Error, "GraphDB check failed [#{resource[:endpoint]}]!"
  end
end
