require 'spec_helper'

describe 'graphdb::install', type: :class do
  let :default_facts do
    {
      operatingsystem: 'Debian',
      operatingsystemmajrelease: '6',
      machine_java_home: '/opt/jdk7'
    }
  end
  describe 'with minimum configuration on Linux' do
    let :facts do
      default_facts.merge(kernel: 'Linux')
    end
    let :pre_condition do
      "class { 'graphdb': version => '7.0.0', edition => 'ee' }"
    end

    let(:download_url) do
      'http://maven.ontotext.com/content/groups/all-onto/com/ontotext/graphdb/graphdb-ee/7.0.0/graphdb-ee-7.0.0-dist.zip'
    end

    let(:dest_file) do
      '/var/tmp/graphdb/graphdb-ee-7.0.0.zip'
    end

    it { is_expected.to contain_class('graphdb::install').that_requires('Class[graphdb]') }
    it do
      is_expected.to contain_file('/opt/graphdb/instances').with(ensure: 'directory',
                                                                 owner: 'graphdb', group: 'graphdb')
    end

    it do
      is_expected.to contain_exec('download-graphdb-ee-7.0.0-archive').with(
        command: "rm -f /var/tmp/graphdb/*.zip && curl --insecure -o #{dest_file}" \
  															" #{download_url} 2> /dev/null",
        creates: dest_file,
        timeout: 600,
        require: ['File[/var/tmp/graphdb]', 'Package[curl]'],
        user: 'graphdb'
      )
    end
    it do
      is_expected.to contain_exec('unpack-graphdb-archive').with(
        command: "rm -rf /opt/graphdb/dist && unzip #{dest_file} -d /opt/graphdb/dist" \
  	' && mv /opt/graphdb/dist/graphdb-ee-7.0.0/* /opt/graphdb/dist && rm -r /opt/graphdb/dist/graphdb-ee-7.0.0',
        refreshonly: true,
        require: 'Package[unzip]',
        user: 'graphdb'
      )
    end
  end

  describe 'with minimum configuration on Darwin' do
    let :facts do
      default_facts.merge(kernel: 'Darwin')
    end
    let :pre_condition do
      "class { 'graphdb': version => '7.0.0', edition => 'ee' }"
    end

    let(:download_url) do
      'http://maven.ontotext.com/content/groups/all-onto/com/ontotext/graphdb/graphdb-ee/7.0.0/graphdb-ee-7.0.0-dist.zip'
    end

    let(:dest_file) do
      '/var/tmp/graphdb/graphdb-ee-7.0.0.zip'
    end

    it do
      is_expected.to contain_exec('download-graphdb-ee-7.0.0-archive').with(
        command: "rm -f /var/tmp/graphdb/*.zip && curl --insecure -o #{dest_file}" \
    															  " #{download_url} 2> /dev/null",
        creates: dest_file,
        timeout: 600,
        require: ['File[/var/tmp/graphdb]', 'Package[curl]'],
        user: 'graphdb'
      )
    end
  end

  describe 'with minimum configuration and custom tmp_dir' do
    let :facts do
      default_facts.merge(kernel: 'Linux')
    end
    let :pre_condition do
      "class { 'graphdb': version => '7.0.0', edition => 'ee', tmp_dir => '/tmp' }"
    end

    let(:download_url) do
      'http://maven.ontotext.com/content/groups/all-onto/com/ontotext/graphdb/graphdb-ee/7.0.0/graphdb-ee-7.0.0-dist.zip'
    end

    let(:dest_file) do
      '/tmp/graphdb-ee-7.0.0.zip'
    end

    it do
      is_expected.to contain_exec('download-graphdb-ee-7.0.0-archive').with(
        command: "rm -f /tmp/*.zip && curl --insecure -o #{dest_file}" \
    													" #{download_url} 2> /dev/null",
        creates: dest_file,
        timeout: 600,
        require: ['File[/tmp]', 'Package[curl]'],
        user: 'graphdb'
      )
    end
    it do
      is_expected.to contain_exec('unpack-graphdb-archive').with(
        command: "rm -rf /opt/graphdb/dist && unzip #{dest_file} -d /opt/graphdb/dist" \
        		' && mv /opt/graphdb/dist/graphdb-ee-7.0.0/* /opt/graphdb/dist && rm -r /opt/graphdb/dist/graphdb-ee-7.0.0',
        refreshonly: true,
        require: 'Package[unzip]',
        user: 'graphdb'
      )
    end
  end

  describe 'with minimum configuration and custom install_dir' do
    let :facts do
      default_facts.merge(kernel: 'Linux')
    end
    let :pre_condition do
      "class { 'graphdb': version => '7.0.0', edition => 'ee', install_dir => '/var/lib' }"
    end

    let(:download_url) do
      'http://maven.ontotext.com/content/groups/all-onto/com/ontotext/graphdb/graphdb-ee/7.0.0/graphdb-ee-7.0.0-dist.zip'
    end

    let(:dest_file) do
      '/var/tmp/graphdb/graphdb-ee-7.0.0.zip'
    end

    it do
      is_expected.to contain_exec('download-graphdb-ee-7.0.0-archive').with(
        command: "rm -f /var/tmp/graphdb/*.zip && curl --insecure -o #{dest_file}" \
    													" #{download_url} 2> /dev/null",
        creates: dest_file,
        timeout: 600,
        require: ['File[/var/tmp/graphdb]', 'Package[curl]'],
        user: 'graphdb'
      )
    end
    it do
      is_expected.to contain_exec('unpack-graphdb-archive').with(
        command: "rm -rf /var/lib/dist && unzip #{dest_file} -d /var/lib/dist" \
       		' && mv /var/lib/dist/graphdb-ee-7.0.0/* /var/lib/dist && rm -r /var/lib/dist/graphdb-ee-7.0.0',
        refreshonly: true,
        require: 'Package[unzip]',
        user: 'graphdb'
      )
    end
  end

  describe 'with minimum configuration and ensure set ot absent' do
    let :facts do
      default_facts.merge(kernel: 'Linux')
    end

    let :pre_condition do
      "class { 'graphdb': version => '7.0.0', edition => 'ee', ensure => 'absent' }"
    end

    it { is_expected.to contain_file('/opt/graphdb/instances').with(ensure: 'absent') }
    it {  is_expected.to contain_file('/opt/graphdb/dist').with(ensure: 'absent') }
    it {  is_expected.to contain_file('/var/tmp/graphdb/graphdb-ee-7.0.0.zip').with(ensure: 'absent') }
  end
end
