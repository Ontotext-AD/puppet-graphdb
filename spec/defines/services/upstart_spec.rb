# frozen_string_literal: true

require 'spec_helper'

describe 'graphdb::service::upstart', type: :define do
  let :facts do
    {
      kernel: 'Linux',
      operatingsystem: 'Ubuntu',
      operatingsystemmajrelease: '6',
      graphdb_java_home: '/opt/jdk8',
      ipaddress: '129.10.1.1'
    }
  end

  let(:title) { 'test' }

  let :pre_condition do
    "class { 'graphdb': version => '9.10.1', edition => 'ee' }"
  end

  context 'with ensure set to present' do
    let(:params) { { ensure: 'present', service_ensure: 'running', service_enable: true } }

    it do
      is_expected.to contain_file('/etc/init/graphdb-test.conf').with(ensure: 'present',
                                                                      owner: 'root',
                                                                      group: 'root',
                                                                      before: "Service[graphdb-#{title}]",
                                                                      notify: "Service[graphdb-#{title}]")
    end

    it { is_expected.to contain_file('/etc/init/graphdb-test.conf').with(content: /description "GraphDB - test"/) }
    it { is_expected.to contain_file('/etc/init/graphdb-test.conf').with(content: /setuid graphdb/) }
    it { is_expected.to contain_file('/etc/init/graphdb-test.conf').with(content: /setgid graphdb/) }

    it { is_expected.to contain_file('/etc/init/graphdb-test.conf').with(content: /JAVA_HOME=\/opt\/jdk8/) }
    it { is_expected.to contain_file('/etc/init/graphdb-test.conf').with(content: /GRAPHDB_INSTALL_DIR=\/opt\/graphdb/) }
    it do
      is_expected.to contain_file('/etc/init/graphdb-test.conf')
        .with(content: /GRAPHDB_INSTANCE_DIR=\$GRAPHDB_INSTALL_DIR\/instances\/test/)
    end

    it do
      is_expected.to contain_service('graphdb-test').with(
        ensure: 'running',
        enable: true,
        name: 'graphdb-test',
        provider: 'upstart',
        hasstatus: true
      )
    end
  end
  context 'with ensure set to absent' do
    let(:params) { { ensure: 'absent', service_ensure: 'disabled', service_enable: false } }

    it do
      is_expected.to contain_file('/etc/init/graphdb-test.conf').with(ensure: 'absent', subscribe: 'Service[graphdb-test]')
    end

    it do
      is_expected.to contain_service('graphdb-test').with(
        ensure: 'disabled',
        enable: false,
        name: 'graphdb-test',
        provider: 'upstart',
        hasstatus: true
      )
    end
  end
end
