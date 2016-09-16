require 'spec_helper'

describe 'graphdb::service::systemd', type: :define do
  let :facts do
    {
      kernel: 'Linux',
      operatingsystem: 'Ubuntu',
      operatingsystemmajrelease: '16',
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
      is_expected.to contain_file('/lib/systemd/system/test.service')
        .with(ensure: 'present',
              owner: 'root',
              group: 'root',
              before: "Service[#{title}]",
              notify: ['Exec[systemd_reload_test]', 'Service[test]'])
    end

    it do
      is_expected.to contain_file('/lib/systemd/system/test.service')
        .with(content: /Description="GraphDB - test"/)
    end
    it do
      is_expected.to contain_file('/lib/systemd/system/test.service')
        .with(content: /Group=graphdb/)
    end
    it do
      is_expected.to contain_file('/lib/systemd/system/test.service')
        .with(content: /User=graphdb/)
    end
    it do
      is_expected.to contain_file('/lib/systemd/system/test.service')
        .with(content: /JAVA_HOME=\/opt\/jdk7/)
    end
    it do
      is_expected.to contain_file('/lib/systemd/system/test.service')
        .with(content: /ExecStart=\/opt\/graphdb\/dist\/bin\/graphdb -Dgraphdb.home=\/opt\/graphdb\/instances\/test/)
    end

    it { is_expected.to contain_exec('systemd_reload_test').with(command: '/bin/systemctl daemon-reload', refreshonly: true) }

    it do
      is_expected.to contain_service('test').with(
        ensure: 'running',
        enable: true,
        name: 'test.service',
        provider: 'systemd',
        hasstatus: true,
        hasrestart: true
      )
    end
  end
  context 'with ensure set to absent' do
    let(:params) { { ensure: 'absent', service_ensure: 'disabled', service_enable: false } }

    it do
      is_expected.to contain_file('/lib/systemd/system/test.service').with(ensure: 'absent', subscribe: 'Service[test]')
    end

    it do
      is_expected.to contain_service('test').with(
        ensure: 'disabled',
        enable: false,
        name: 'test.service',
        provider: 'systemd',
        hasstatus: true,
        hasrestart: true
      )
    end
    it { is_expected.to contain_exec('systemd_reload_test').with(command: '/bin/systemctl daemon-reload', refreshonly: true) }
  end
end
