require 'spec_helper'

describe 'graphdb::service::init', type: :define do
  let :facts do
    {
      kernel: 'Linux',
      operatingsystem: 'Ubuntu',
      operatingsystemmajrelease: '6',
      machine_java_home: '/opt/jdk7',
      ipaddress: '127.0.0.1'
    }
  end

  let(:title) { 'test' }

  let :pre_condition do
    "class { 'graphdb': version => '7.0.0', edition => 'ee' }"
  end

  context 'with ensure set to present' do
    let(:params) { { ensure: 'present', service_ensure: 'running', service_enable: true } }

    it do
      is_expected.to contain_file('/etc/init.d/test').with(ensure: 'present',
                                                           owner: 'root',
                                                           group: 'root',
                                                           before: "Service[#{title}]",
                                                           notify: "Service[#{title}]")
    end

    it { is_expected.to contain_file('/etc/init.d/test').with(content: /NAME=graphdb-test/) }
    it { is_expected.to contain_file('/etc/init.d/test').with(content: /GRAPHDB_USER=graphdb/) }
    it { is_expected.to contain_file('/etc/init.d/test').with(content: /JAVA_HOME=\/opt\/jdk7/) }
    it { is_expected.to contain_file('/etc/init.d/test').with(content: /GRAPHDB_INSTALL_DIR=\/opt\/graphdb/) }
    it { is_expected.to contain_file('/etc/init.d/test').with(content: /GRAPHDB_INSTANCE_DIR=\$GRAPHDB_INSTALL_DIR\/instances\/test/) }

    it do
      is_expected.to contain_service('test').with(
        ensure: 'running',
        enable: true,
        name: 'test',
        provider: 'init',
        hasstatus: true,
        hasrestart: true
      )
    end
  end
  context 'with ensure set to absent' do
    let(:params) { { ensure: 'absent', service_ensure: 'disabled', service_enable: false } }

    it do
      is_expected.to contain_file('/etc/init.d/test').with(ensure: 'absent', subscribe: 'Service[test]')
    end

    it do
      is_expected.to contain_service('test').with(
        ensure: 'disabled',
        enable: false,
        name: 'test',
        provider: 'init',
        hasstatus: true,
        hasrestart: true
      )
    end
  end
end
