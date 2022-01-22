# frozen_string_literal: true

require 'spec_helper'

describe Puppet::Type.type(:graphdb_update) do
  let(:repository_id) { 'test' }
  let(:endpoint) { 'http://test.com' }
  let(:update_query) { 'update\nquery' }
  let(:exists_query) { 'exists query' }
  let(:exists_expected_response) { true }

  let(:timeout) { '60' }

  context 'with string endpoint and timeout' do
    let :graphdb_update do
      Puppet::Type.type(:graphdb_update).new(name: 'foo',
                                             repository_id: repository_id,
                                             endpoint: endpoint,
                                             update_query: update_query,
                                             exists_query: exists_query,
                                             exists_expected_response: exists_expected_response,
                                             timeout: timeout)
    end

    it 'should pass munge on every param' do
      expect(graphdb_update[:endpoint]).to eq(URI(endpoint))
      expect(graphdb_update[:timeout]).to eq(Integer(timeout))
      expect(graphdb_update[:update_query]).to eq('update query')
    end
  end

  context 'with no repository_id provided' do
    let :graphdb_update do
      Puppet::Type.type(:graphdb_update).new(name: 'foo',
                                             endpoint: endpoint,
                                             update_query: update_query,
                                             exists_query: exists_query,
                                             exists_expected_response: exists_expected_response,
                                             timeout: timeout)
    end

    it do
      expect(graphdb_update[:repository_id]).to eq(graphdb_update[:name])
    end
  end

  context 'with not valid endpoint' do
    it do
      expect do
        Puppet::Type.type(:graphdb_update).new(name: 'foo',
                                               repository_id: repository_id,
                                               endpoint: 'not valid uri',
                                               update_query: update_query,
                                               exists_query: exists_query,
                                               exists_expected_response: exists_expected_response,
                                               timeout: timeout)
      end
        .to raise_error(Puppet::ResourceError, /endpoint should be valid url: not valid uri/)
    end
  end

  context 'with not valid timeout' do
    it do
      expect do
        Puppet::Type.type(:graphdb_update).new(name: 'foo',
                                               repository_id: repository_id,
                                               endpoint: endpoint,
                                               update_query: update_query,
                                               exists_query: exists_query,
                                               exists_expected_response: exists_expected_response,
                                               timeout: 'not valid timeout')
      end
        .to raise_error(Puppet::ResourceError, /timeout should be valid integer: not valid timeout/)
    end
  end

  it 'should autorequire graphdb_repository if endpoint and http_port matches' do
    catalog = Puppet::Resource::Catalog.new
    graphdb_repository = Puppet::Type.type(:graphdb_repository).new(name: 'foo',
                                                                    endpoint: endpoint,
                                                                    repository_id: repository_id)
    graphdb_update = Puppet::Type.type(:graphdb_update).new(name: 'foo',
                                                            repository_id: repository_id,
                                                            endpoint: endpoint,
                                                            update_query: update_query,
                                                            exists_query: exists_query,
                                                            exists_expected_response: exists_expected_response,
                                                            timeout: timeout)

    catalog.add_resource graphdb_repository
    catalog.add_resource graphdb_update

    relationship = graphdb_update.autorequire.find do |rel|
      (rel.source.to_s == 'Graphdb_repository[foo]') && (rel.target.to_s == graphdb_update.to_s)
    end
    expect(relationship).to be_a Puppet::Relationship
  end

  it 'should not autorequire any graphdb_repository if it is not managed' do
    catalog = Puppet::Resource::Catalog.new
    graphdb_update = Puppet::Type.type(:graphdb_update).new(name: 'foo',
                                                            repository_id: repository_id,
                                                            endpoint: endpoint,
                                                            update_query: update_query,
                                                            exists_query: exists_query,
                                                            exists_expected_response: exists_expected_response,
                                                            timeout: timeout)
    catalog.add_resource graphdb_update
    expect(graphdb_update.autorequire).to be_empty
  end
end
