require 'spec_helper'
require 'puppet/util/link_manager'

provider_class = Puppet::Type.type(:graphdb_link).provider(:graphdb_link)

describe provider_class do
  let(:uri) { 'http://test.com' }
  let(:master_repository_id) { 'master' }
  let(:master_endpoint) { "#{uri}/master" }
  let(:worker_repository_id) { 'worker' }
  let(:worker_endpoint) { "#{uri}/worker" }
  let(:replication_port) { 9000 }
  let(:jolokia_secret) { 'secret' }

  let(:catalog) { double 'catalog' }

  let(:master_instance) { double 'master_instance' }

  let :resource do
    Puppet::Type::Graphdb_link.new(
      name: 'foo',
      master_repository_id: master_repository_id,
      master_endpoint: master_endpoint,
      worker_repository_id: worker_repository_id,
      worker_endpoint: worker_endpoint,
      replication_port: replication_port
    )
  end

  let :provider do
    provider_class.new(resource)
  end

  context 'with unresolvable jolokia_secret' do
    before do
      allow_any_instance_of(Puppet::Type::Graphdb_link).to receive(:catalog) { catalog }
      allow(catalog).to receive(:resources) { [master_instance] }
      allow(master_instance).to receive(:type) { :component }
      allow(master_instance).to receive(:[]).with(:http_port) { '90' }
    end

    it do
      expect { provider.exists? }.to raise_error(Puppet::Error, /fail to resolve julokia secret/)
    end
  end

  context 'with resolvable jolokia_secret' do
    before do
      allow_any_instance_of(Puppet::Type::Graphdb_link).to receive(:catalog) { catalog }
      allow(catalog).to receive(:resources) { [master_instance] }
      allow(master_instance).to receive(:type) { :component }
      allow(master_instance).to receive(:[]).with(:http_port) { '80' }
      allow(master_instance).to receive(:[]).with(:jolokia_secret) { jolokia_secret }
    end

    context 'validating existing link' do
      it 'should detect that link is existing' do
        allow_any_instance_of(Puppet::Util::LinkManager).to receive(:check_link) { true }
        expect_any_instance_of(Puppet::Util::LinkManager).to receive(:check_link).once

        expect(provider.exists?).to be true
      end
    end

    context 'creating link with creation success' do
      it 'should request create for link and return true' do
        allow_any_instance_of(Puppet::Util::LinkManager).to receive(:create_link) { true }
        expect_any_instance_of(Puppet::Util::LinkManager).to receive(:create_link).once

        expect(provider.create).to be true
      end
    end

    context 'creating link with creation fail' do
      it 'should request create for link and return false' do
        allow_any_instance_of(Puppet::Util::LinkManager).to receive(:create_link) { false }
        expect_any_instance_of(Puppet::Util::LinkManager).to receive(:create_link).once

        expect(provider.create).to be false
      end
    end

    context 'deleting link' do
      it 'should request delete for link and return true' do
        allow_any_instance_of(Puppet::Util::LinkManager).to receive(:delete_link) { true }
        expect_any_instance_of(Puppet::Util::LinkManager).to receive(:delete_link).once

        expect(provider.destroy).to be true
      end
    end

    context 'deleting link with deletion fail' do
      it 'should request delete for link and return false' do
        allow_any_instance_of(Puppet::Util::LinkManager).to receive(:delete_link) { false }
        expect_any_instance_of(Puppet::Util::LinkManager).to receive(:delete_link).once

        expect(provider.destroy).to be false
      end
    end
  end
end
