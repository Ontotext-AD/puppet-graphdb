require 'spec_helper'

describe 'graphdb::ee::master::repository', type: :define do
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
    let(:params) { { endpoint: 'http://test.com', repository_context: 'test:test' } }

    it do
      is_expected.to contain_graphdb__ee__master__repository('test')
      is_expected.to contain_graphdb_repository('test')
        .with(ensure: 'present',
              repository_id: 'test',
              endpoint: 'http://test.com',
              repository_context: 'test:test')
    end
  end

  context 'with ensure set to absent' do
    let(:params) { { ensure: 'absent', endpoint: 'http://test.com', repository_context: 'test:test' } }

    it do
      is_expected.to contain_graphdb__ee__master__repository('test')
      is_expected.to contain_graphdb_repository('test')
        .with(ensure: 'absent',
              repository_id: 'test',
              endpoint: 'http://test.com',
              repository_context: 'test:test')
    end
  end
end
