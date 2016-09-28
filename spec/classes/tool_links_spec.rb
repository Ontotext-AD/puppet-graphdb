require 'spec_helper'

describe 'graphdb::tool_links', type: :class do
  let :facts do
    {
      kernel: 'Linux',
      operatingsystem: 'Debian',
      operatingsystemmajrelease: '6',
      machine_java_home: '/opt/jdk7'
    }
  end

  %w(present absent).each do |ensure_param|
    context "graphdb ensure set to #{ensure_param}" do
      let :pre_condition do
        "class { 'graphdb': ensure => #{ensure_param}, version => '7.0.0', edition => 'ee' }"
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
          is_expected.to contain_file("/bin/#{tool}")
            .with(ensure: link_ensure, target: "/opt/graphdb/dist/bin/#{tool}", owner: 'graphdb', group: 'graphdb')
        end
      end
    end
  end
end
