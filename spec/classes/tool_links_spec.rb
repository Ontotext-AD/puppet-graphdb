# frozen_string_literal: true

require 'spec_helper'

describe 'graphdb::tool_links', type: :class do
  let :facts do
    {
      kernel: 'Linux',
      operatingsystem: 'Debian',
      operatingsystemmajrelease: '6',
      machine_java_home: '/opt/jdk8'
    }
  end

  %w(present absent).each do |ensure_param|
    context "graphdb ensure set to #{ensure_param}" do
      let :pre_condition do
        "class { 'graphdb': ensure => #{ensure_param}, version => '9.10.1', edition => 'ee' }"
      end

      link_ensure = if ensure_param == 'present'
                      'link'
                    else
                      'absent'
      end
      it do
        is_expected.to contain_class('graphdb::tool_links')
      end

      %w(console loadrdf migration-wizard rdfvalidator report rule-compiler storage-tool).each do |tool|
        it do
          if ensure_param == 'present'
            file_param = { ensure: link_ensure, target: "/opt/graphdb/dist/bin/#{tool}", owner: 'graphdb', group: 'graphdb' }
          else
            file_param = { ensure: link_ensure, target: "/opt/graphdb/dist/bin/#{tool}" }
          end
          is_expected.to contain_file("/bin/#{tool}").with(file_param)
        end
      end
    end
  end
end
