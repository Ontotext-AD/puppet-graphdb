# frozen_string_literal: true

require 'spec_helper'

describe 'graphdb::service', type: :define do
  let :default_facts do
    {
      kernel: 'Linux',
      machine_java_home: '/opt/jdk8'
    }
  end

  let(:title) { 'test' }

  let :pre_condition do
    "class { 'graphdb': version => '9.10.1', edition => 'ee' }"
  end

  { 'enabled' => ['running', true],
    'disabled' => ['stopped', false],
    'running' => ['running', false],
    'unmanaged' => [nil, false] }
    .each do |status_param, service_status|
    context 'Ubuntu 12' do
      let(:facts) { default_facts.merge(operatingsystem: 'Ubuntu', operatingsystemmajrelease: '12') }

      context "with ensure set to: [present] and status set to: [#{status_param}]" do
        let(:params) { { ensure: 'present', status: status_param } }

        it do
          is_expected.to contain_graphdb__service__upstart(title).with(
            ensure: 'present',
            service_ensure: service_status[0],
            service_enable: service_status[1]
          )
        end
      end

      context "with ensure set to: [absent] and status set to: [#{status_param}]" do
        let(:params) { { ensure: 'absent', status:  status_param } }

        it do
          is_expected.to contain_graphdb__service__upstart(title).with(
            ensure: 'absent',
            service_ensure: 'stopped',
            service_enable: false
          )
        end
      end
    end

    context 'Debian 10' do
      let(:facts) { default_facts.merge(operatingsystem: 'Debian', operatingsystemmajrelease: '10') }

      context "with ensure set to: [present] and status set to: [#{status_param}]" do
        let(:params) { { ensure: 'present', status:  status_param } }

        it do
          is_expected.to contain_graphdb__service__systemd(title).with(
            ensure: 'present',
            service_ensure: service_status[0],
            service_enable: service_status[1]
          )
        end
      end

      context "with ensure set to: [absent] and status set to: [#{status_param}]" do
        let(:params) { { ensure: 'absent', status:  status_param } }

        it do
          is_expected.to contain_graphdb__service__systemd(title).with(
            ensure: 'absent',
            service_ensure: 'stopped',
            service_enable: false
          )
        end
      end
    end

    context 'Debian 7' do
      let(:facts) { default_facts.merge(operatingsystem: 'Debian', operatingsystemmajrelease: '7') }

      context "with ensure set to: [present] and status set to: [#{status_param}]" do
        let(:params) { { ensure: 'present', status:  status_param } }

        it do
          is_expected.to contain_graphdb__service__init(title).with(
            ensure: 'present',
            service_ensure: service_status[0],
            service_enable: service_status[1]
          )
        end
      end

      context "with ensure set to: [absent] and status set to: [#{status_param}]" do
        let(:params) { { ensure: 'absent', status:  status_param } }

        it do
          is_expected.to contain_graphdb__service__init(title).with(
            ensure: 'absent',
            service_ensure: 'stopped',
            service_enable: false
          )
        end
      end
    end
  end
end
