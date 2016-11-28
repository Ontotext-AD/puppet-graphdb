require 'spec_helper'
require 'puppet/util/repository_manager'

provider_class = Puppet::Type.type(:graphdb_update).provider(:graphdb_update)

describe provider_class do
  let(:repository_id) { 'test' }
  let(:endpoint) { 'http://test.com' }
  let(:update_query) { 'update query' }
  let(:exists_query) { 'exists query' }
  let(:exists_expected_response) { true }
  let(:timeout) { 60 }

  let :resource do
    Puppet::Type::Graphdb_update.new(
      name: 'foo',
      repository_id: repository_id,
      endpoint: endpoint,
      update_query: update_query,
      exists_query: exists_query,
      exists_expected_response: exists_expected_response,
      timeout: timeout
    )
  end

  let :provider do
    provider_class.new(resource)
  end

  context 'validating applied update' do
    it 'should detect that update is applied' do
      allow_any_instance_of(Puppet::Util::RepositoryManager).to receive(:ask)
        .with(exists_query, exists_expected_response, 0) { true }
      expect_any_instance_of(Puppet::Util::RepositoryManager).to receive(:ask)
        .with(exists_query, exists_expected_response, 0).once

      expect(provider.exists?).to be true
    end
  end

  context 'validating not applied update' do
    it 'should detect that update is not applied' do
      allow_any_instance_of(Puppet::Util::RepositoryManager).to receive(:ask)
        .with(exists_query, exists_expected_response, 0).and_raise(Puppet::Exceptions::RequestFailError)
      expect_any_instance_of(Puppet::Util::RepositoryManager).to receive(:ask)
        .with(exists_query, exists_expected_response, 0).once

      expect(provider.exists?).to be false
    end
  end

  context 'apply update with success' do
    it 'should request update_query and return true' do
      allow_any_instance_of(Puppet::Util::RepositoryManager).to receive(:update_query)
        .with(update_query, timeout) { true }
      expect_any_instance_of(Puppet::Util::RepositoryManager).to receive(:update_query)
        .with(update_query, timeout).once

      expect(provider.create).to be true
    end
  end

  context 'apply update with fail' do
    it 'should request update_query and return false' do
      allow_any_instance_of(Puppet::Util::RepositoryManager).to receive(:update_query)
        .with(update_query, timeout) { false }
      expect_any_instance_of(Puppet::Util::RepositoryManager).to receive(:update_query)
        .with(update_query, timeout).once

      expect(provider.create).to be false
    end
  end
end
