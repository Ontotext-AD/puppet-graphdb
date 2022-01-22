# frozen_string_literal: true

require 'spec_helper'

describe Puppet::Type.type(:graphdb_validator) do
  let(:endpoint) { 'http://test.com' }
  let(:timeout) { '60' }

  context 'with all needed params' do
    let :graphdb_validator do
      Puppet::Type.type(:graphdb_validator).new(name: 'foo', endpoint: endpoint, timeout: timeout)
    end

    it 'should pass munge on every param' do
      expect(graphdb_validator[:endpoint]).to eq(URI(endpoint))
      expect(graphdb_validator[:timeout]).to eq(Integer(timeout))
    end
  end

  context 'with not valid endpoint' do
    it do
      expect { Puppet::Type.type(:graphdb_validator).new(name: 'foo', endpoint: 'not valid uri', timeout: timeout) }
        .to raise_error(Puppet::ResourceError, /endpoint should be valid url: not valid uri/)
    end
  end

  context 'with not valid timeout' do
    it do
      expect do
        Puppet::Type.type(:graphdb_validator).new(name: 'foo',
                                                  endpoint: endpoint,
                                                  timeout: 'not valid timeout')
      end
        .to raise_error(Puppet::ResourceError, /timeout should be valid integer: not valid timeout/)
    end
  end

  it 'should autorequire service if service name matches validator\'s name' do
    catalog = Puppet::Resource::Catalog.new
    service = Puppet::Type.type(:service).new(name: 'foo')
    validator = Puppet::Type.type(:graphdb_validator).new(name: 'foo', endpoint: endpoint, timeout: timeout)

    catalog.add_resource service
    catalog.add_resource validator

    relationship = validator.autorequire.find do |rel|
      (rel.source.to_s == 'Service[foo]') && (rel.target.to_s == validator.to_s)
    end
    expect(relationship).to be_a Puppet::Relationship
  end

  it 'should not autorequire service if service name doesn\'t match validator\'s name' do
    catalog = Puppet::Resource::Catalog.new
    service = Puppet::Type.type(:service).new(name: 'foo')
    validator = Puppet::Type.type(:graphdb_validator).new(name: 'bar', endpoint: endpoint, timeout: timeout)

    catalog.add_resource service
    catalog.add_resource validator

    expect(validator.autorequire).to be_empty
  end
end
