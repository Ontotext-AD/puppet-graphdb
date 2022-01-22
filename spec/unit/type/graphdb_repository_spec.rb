# frozen_string_literal: true

require 'spec_helper'

describe Puppet::Type.type(:graphdb_repository) do
  let(:repository_id) { 'test' }
  let(:endpoint) { 'http://test.com' }
  let(:repository_template) { 'repository template' }
  let(:repository_context) { 'repository context' }
  let(:timeout) { '60' }

  context 'with all needed params' do
    let :graphdb_repository do
      Puppet::Type.type(:graphdb_repository).new(name: 'foo',
                                                 repository_id: repository_id,
                                                 endpoint: endpoint,
                                                 repository_template: repository_template,
                                                 repository_context: repository_context,
                                                 timeout: timeout)
    end

    it 'should pass munge on every param' do
      expect(graphdb_repository[:endpoint]).to eq(URI(endpoint))
      expect(graphdb_repository[:timeout]).to eq(Integer(timeout))
    end
  end

  context 'with no repository_id provided' do
    let :graphdb_repository do
      Puppet::Type.type(:graphdb_repository).new(name: 'foo',
                                                 endpoint: endpoint,
                                                 repository_template: repository_template,
                                                 repository_context: repository_context,
                                                 timeout: timeout)
    end

    it do
      expect(graphdb_repository[:repository_id]).to eq(graphdb_repository[:name])
    end
  end

  context 'with not valid endpoint' do
    it do
      expect do
        Puppet::Type.type(:graphdb_repository).new(name: 'foo',
                                                   repository_id: repository_id,
                                                   endpoint: 'not valid uri',
                                                   repository_template: repository_template,
                                                   repository_context: repository_context,
                                                   timeout: timeout)
      end
        .to raise_error(Puppet::ResourceError, /endpoint should be valid url: not valid uri/)
    end
  end

  context 'with not valid timeout' do
    it do
      expect do
        Puppet::Type.type(:graphdb_repository).new(name: 'foo',
                                                   repository_id: repository_id,
                                                   endpoint: endpoint,
                                                   repository_template: repository_template,
                                                   repository_context: repository_context,
                                                   timeout: 'not valid timeout')
      end
        .to raise_error(Puppet::ResourceError, /timeout should be valid integer: not valid timeout/)
    end
  end

  it 'should autorequire graphdb_validator if endpoint matches' do
    catalog = Puppet::Resource::Catalog.new
    graphdb_validator = Puppet::Type.type(:graphdb_validator).new(name: 'foo',
                                                                  endpoint: endpoint)
    graphdb_repository = Puppet::Type.type(:graphdb_repository).new(name: 'foo',
                                                                    repository_id: repository_id,
                                                                    endpoint: endpoint,
                                                                    repository_template: repository_template,
                                                                    repository_context: repository_context,
                                                                    timeout: timeout)

    catalog.add_resource graphdb_validator
    catalog.add_resource graphdb_repository

    relationship = graphdb_repository.autorequire.find do |rel|
      (rel.source.to_s == 'Graphdb_validator[foo]') && (rel.target.to_s == graphdb_repository.to_s)
    end
    expect(relationship).to be_a Puppet::Relationship
  end

  it 'should not autorequire any graphdb_validator if endpoint doesn\'t match' do
    catalog = Puppet::Resource::Catalog.new
    graphdb_validator = Puppet::Type.type(:graphdb_validator).new(name: 'foo',
                                                                  endpoint: 'http://test2.com')
    graphdb_repository = Puppet::Type.type(:graphdb_repository).new(name: 'foo',
                                                                    repository_id: repository_id,
                                                                    endpoint: endpoint,
                                                                    repository_template: repository_template,
                                                                    repository_context: repository_context,
                                                                    timeout: timeout)
    catalog.add_resource graphdb_repository
    catalog.add_resource graphdb_validator
    expect(graphdb_repository.autorequire).to be_empty
  end
end
