# frozen_string_literal: true

require 'spec_helper'

describe 'graphdb::data', type: :define do
  let :facts do
    {
      kernel: 'Linux',
      operatingsystem: 'Ubuntu',
      operatingsystemmajrelease: '6',
      machine_java_home: '/opt/jdk8',
      ipaddress: '129.10.1.1'
    }
  end

  let(:title) { 'test' }

  let :pre_condition do
    "class { 'graphdb': version => '9.10.1', edition => 'ee' }"
  end

  context 'with archive' do
    let(:params) do
      { endpoint: 'http://test.com',
        repository: 'test',
        exists_query: 'ask { ?s ?p ?o }',
        archive: 'test.zip' }
    end

    it { is_expected.to contain_graphdb__data(title).that_requires('Class[graphdb]') }
    it do
      is_expected.to contain_file("/var/tmp/graphdb/#{title}").with(ensure: 'directory',
                                                                    owner: 'graphdb',
                                                                    group: 'graphdb')
    end
    it do
      is_expected.to contain_file('/var/tmp/graphdb/test/test.zip')
        .with(ensure: 'present',
              source: 'test.zip',
              owner: 'graphdb',
              group: 'graphdb',
              require: "File[/var/tmp/graphdb/#{title}]",
              notify: "Exec[unpack-archive-source-#{title}]")
    end
    it do
      is_expected.to contain_exec("unpack-archive-source-#{title}")
        .with(command: "rm -rf /var/tmp/graphdb/#{title}/unpacked "\
    "&& unzip /var/tmp/graphdb/#{title}/test.zip -d /var/tmp/graphdb/#{title}/unpacked",
              refreshonly: true,
              user: 'graphdb',
              require: ['Package[unzip]', "File[/var/tmp/graphdb/#{title}]"],
              notify: "Graphdb_data[#{title}]")
    end
    it do
      is_expected.to contain_graphdb_data(title)
        .with(endpoint: 'http://test.com',
              repository_id: 'test',
              exists_query: 'ask { ?s ?p ?o }',
              data_source: "/var/tmp/graphdb/#{title}/unpacked",
              data: nil,
              data_format: nil,
              data_context: 'null',
              data_overwrite: false,
              exists_expected_response: true,
              timeout: 200)
    end
    context 'with source' do
      let(:params) do
        { endpoint: 'http://test.com',
          repository: 'test',
          exists_query: 'ask { ?s ?p ?o }',
          source: 'test source' }
      end
      it do
        is_expected.to contain_graphdb_data(title)
          .with(endpoint: 'http://test.com',
                repository_id: 'test',
                exists_query: 'ask { ?s ?p ?o }',
                data_source: 'test source',
                data: nil,
                data_format: nil,
                data_context: 'null',
                data_overwrite: false,
                exists_expected_response: true,
                timeout: 200)
      end
    end
  end
end
