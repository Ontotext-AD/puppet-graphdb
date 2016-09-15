require 'spec_helper'
require 'puppet/util/repository_manager'

provider_class = Puppet::Type.type(:graphdb_repository).provider(:graphdb_repository)

describe provider_class do
  let(:uri) { 'http://test.com' }
  let(:repository_id) { 'test' }
  let(:repository_template) { 'test_template' }
  let(:repository_context) { 'test_context' }
  let(:timeout) { 0 }

  let :resource do
    Puppet::Type::Graphdb_repository.new(
      name: 'foo', endpoint: uri,
      repository_id: repository_id,
      repository_template: repository_template,
      repository_context: repository_context,
      timeout: timeout
    )
  end

  let :provider do
    provider_class.new(resource)
  end

  context 'validating existing graphdb repository' do
    it 'should detect that graphdb repository is existing' do
      allow_any_instance_of(Puppet::Util::RepositoryManager).to receive(:check_repository).with(timeout) { true }
      expect_any_instance_of(Puppet::Util::RepositoryManager).to receive(:check_repository).once

      expect(provider.exists?).to be true
    end
  end

  context 'validating not existing graphdb repository' do
    it 'should detect that graphdb repository is not existing' do
      allow_any_instance_of(Puppet::Util::RepositoryManager).to receive(:check_repository).with(timeout) { false }
      expect_any_instance_of(Puppet::Util::RepositoryManager).to receive(:check_repository).once

      expect(provider.exists?).to be false
    end
  end

  context 'creating new repository' do
    it 'should try to create new graphdb repository and try to verify the newly created repository' do
      allow_any_instance_of(Puppet::Util::RepositoryManager).to receive(:check_repository)
        .with(timeout).and_return(true)
      allow_any_instance_of(Puppet::Util::RepositoryManager).to receive(:create_repository)
        .with(repository_template, repository_context, timeout) { true }

      expect_any_instance_of(Puppet::Util::RepositoryManager).to receive(:check_repository).once
      expect_any_instance_of(Puppet::Util::RepositoryManager).to receive(:create_repository).once

      expect(provider.create).to be true
    end

    context 'with repository creation fail' do
      it 'should try to create new graphdb repository and return false' do
        allow_any_instance_of(Puppet::Util::RepositoryManager).to receive(:create_repository)
          .with(repository_template, repository_context, timeout) { false }

        expect_any_instance_of(Puppet::Util::RepositoryManager).to receive(:create_repository).once
        expect(provider.create).to be false
      end
    end
  end

  context 'deleting existing graphdb repository' do
    it 'should request delete for repository and return true' do
      allow_any_instance_of(Puppet::Util::RepositoryManager).to receive(:delete_repository).with(timeout) { true }
      expect_any_instance_of(Puppet::Util::RepositoryManager).to receive(:delete_repository).once

      expect(provider.destroy).to be true
    end
  end

  context 'deleting not existing graphdb repository' do
    it 'should request delete for repository and return false' do
      allow_any_instance_of(Puppet::Util::RepositoryManager).to receive(:delete_repository).with(timeout) { false }
      expect_any_instance_of(Puppet::Util::RepositoryManager).to receive(:delete_repository).once

      expect(provider.destroy).to be false
    end
  end
end
