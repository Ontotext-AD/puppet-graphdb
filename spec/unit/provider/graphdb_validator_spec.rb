# frozen_string_literal: true

require 'spec_helper'
require 'webmock/rspec'

provider_class = Puppet::Type.type(:graphdb_validator).provider(:graphdb_validator)

describe provider_class do
  let(:uri) { 'http://test.com' }

  let :resource do
    Puppet::Type::Graphdb_validator.new(
      name: 'foo', endpoint: uri, timeout: 0
    )
  end

  let :provider do
    provider_class.new(resource)
  end

  context 'validating running graphdb instance' do
    it 'should detect that graphdb is running' do
      final_uri = URI(uri)
      final_uri.path = '/protocol'
      stub_request(:get, final_uri)
      expect(provider.exists?).to be true
    end
  end

  context 'validating not running graphdb instance' do
    it 'should detect that graphdb is not running' do
      final_uri = URI(uri)
      final_uri.path = '/protocol'
      stub_request(:get, final_uri).to_return(status: [404])
      expect(provider.exists?).to be false
    end
  end
end
