# frozen_string_literal: true

require 'spec_helper'

describe 'graphdb::service::params', type: :class do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      it { is_expected.to contain_class('graphdb::service::params') }
    end
  end

  context 'unknown operatingsystem' do
    let :facts do
      {
        kernel: 'Linux',
        operatingsystem: 'unknown',
        operatingsystemmajrelease: '6'
      }
    end
    it do
      expect { is_expected.to contain_class('graphdb::params') }.to raise_error(Puppet::ParseError)
    end
  end
end