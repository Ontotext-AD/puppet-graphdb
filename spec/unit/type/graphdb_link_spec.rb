# frozen_string_literal: true

require 'spec_helper'

describe Puppet::Type.type(:graphdb_link) do
  let(:master_repository_id) { 'master' }
  let(:master_endpoint) { "http://test.com/#{master_repository_id}" }
  let(:worker_repository_id) { 'worker' }
  let(:worker_endpoint) { "http://test.com/#{worker_repository_id}" }
  let(:replication_port) { 9000 }

  context 'with all needed params' do
    let :graphdb_link do
      Puppet::Type.type(:graphdb_link).new(name: 'foo',
                                           master_repository_id: master_repository_id,
                                           master_endpoint: master_endpoint,
                                           worker_repository_id: worker_repository_id,
                                           worker_endpoint: worker_endpoint,
                                           replication_port: replication_port)
    end

    it 'should pass munge on every param' do
      expect(graphdb_link[:master_endpoint]).to eq(URI(master_endpoint))
      expect(graphdb_link[:worker_endpoint]).to eq(URI(worker_endpoint))
      expect(graphdb_link[:replication_port]).to eq(Integer(replication_port))
    end
  end

  context 'with not valid master endpoint' do
    it do
      expect do
        Puppet::Type.type(:graphdb_link).new(name: 'foo',
                                             master_repository_id: master_repository_id,
                                             master_endpoint: 'not valid uri',
                                             worker_repository_id: worker_repository_id,
                                             worker_endpoint: worker_endpoint,
                                             replication_port: replication_port)
      end
        .to raise_error(Puppet::ResourceError, /master_endpoint should be valid url: not valid uri/)
    end
  end

  context 'with not valid worker endpoint' do
    it do
      expect do
        Puppet::Type.type(:graphdb_link).new(name: 'foo',
                                             master_repository_id: master_repository_id,
                                             master_endpoint: master_endpoint,
                                             worker_repository_id: worker_repository_id,
                                             worker_endpoint: 'not valid uri',
                                             replication_port: replication_port)
      end
        .to raise_error(Puppet::ResourceError, /worker_endpoint should be valid url: not valid uri/)
    end
  end

  context 'with not valid replication port' do
    it do
      expect do
        Puppet::Type.type(:graphdb_link).new(name: 'foo',
                                             master_repository_id: master_repository_id,
                                             master_endpoint: master_endpoint,
                                             worker_repository_id: worker_repository_id,
                                             worker_endpoint: worker_endpoint,
                                             replication_port: 'not valid replication port')
      end
        .to raise_error(Puppet::ResourceError, /replication_port should be valid integer: not valid replication port/)
    end
  end

  it 'should autorequire graphdb_repository if master endpoint and master http_port matches' do
    catalog = Puppet::Resource::Catalog.new
    graphdb_repository = Puppet::Type.type(:graphdb_repository).new(name: 'foo',
                                                                    endpoint: master_endpoint,
                                                                    repository_id: master_repository_id)
    graphdb_link = Puppet::Type.type(:graphdb_link).new(name: 'foo',
                                                        master_repository_id: master_repository_id,
                                                        master_endpoint: master_endpoint,
                                                        worker_repository_id: worker_repository_id,
                                                        worker_endpoint: worker_endpoint,
                                                        replication_port: replication_port)

    catalog.add_resource graphdb_repository
    catalog.add_resource graphdb_link

    relationship = graphdb_link.autorequire.find do |rel|
      (rel.source.to_s == 'Graphdb_repository[foo]') && (rel.target.to_s == graphdb_link.to_s)
    end
    expect(relationship).to be_a Puppet::Relationship
  end

  it 'should not autorequire any graphdb_repository if it is not managed' do
    catalog = Puppet::Resource::Catalog.new
    graphdb_link = Puppet::Type.type(:graphdb_link).new(name: 'foo',
                                                        master_repository_id: master_repository_id,
                                                        master_endpoint: master_endpoint,
                                                        worker_repository_id: worker_repository_id,
                                                        worker_endpoint: worker_endpoint,
                                                        replication_port: replication_port)
    catalog.add_resource graphdb_link
    expect(graphdb_link.autorequire).to be_empty
  end
end
