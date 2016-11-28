require 'spec_helper'

describe 'graphdb::ee::backup_cron', type: :define do
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
    let(:params) { { master_endpoint: 'http://test.com', master_repository: 'test', jolokia_secret: 'test secret' } }

    it { is_expected.to contain_graphdb__ee__backup_cron('test').that_requires('Class[graphdb]') }
    it do
      is_expected.to contain_file('/opt/graphdb/test').with(ensure: 'present',
                                                            source: 'puppet:///modules/graphdb/cron/backup.sh',
                                                            owner: 'graphdb',
                                                            group: 'graphdb',
                                                            mode: '0755')
    end
    it do
      is_expected.to contain_cron('test')
        .with(ensure: 'present',
              command: '/opt/graphdb/test http://test.com test test secret >> /opt/graphdb/test.log 2>&1',
              hour: nil,
              minute: nil,
              weekday: nil,
              month: nil,
              monthday: nil,
              user: 'graphdb',
              require: ['Package[curl]', 'File[/opt/graphdb/test]'])
    end
  end
  context 'with ensure set to absent' do
    let(:params) { { ensure: 'absent', master_endpoint: 'http://test.com', master_repository: 'test', jolokia_secret: 'test secret' } }

    it { is_expected.to contain_graphdb__ee__backup_cron('test').that_requires('Class[graphdb]') }
    it do
      is_expected.to contain_file('/opt/graphdb/test').with(ensure: 'absent')
    end
    it do
      is_expected.to contain_cron('test')
        .with(ensure: 'absent')
    end
  end
end
