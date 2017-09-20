require 'spec_helper_acceptance'

describe 'graphdb::instance', unless: UNSUPPORTED_PLATFORMS.include?(fact('osfamily')) do
  graphdb_version = ENV['GRAPHDB_VERSION']
  graphdb_timeout = ENV['GRAPHDB_TIMEOUT']

  %w[ee se].each do |graphdb_edition|
    context "#{graphdb_edition} installation" do
      let(:manifest) do
        <<-EOS
			 class{ 'graphdb':
			 version              => '#{graphdb_version}',
			 edition              => '#{graphdb_edition}',
			 graphdb_download_url => 'file:///tmp',
			 }

			 graphdb::instance { 'test':
  		 		license           => '/tmp/#{graphdb_edition}.license',
  				jolokia_secret    => 'duper',
  				http_port         => 8080,
				validator_timeout => #{graphdb_timeout},
				heap_size         => '256m',
        external_url      => 'http://test.com/graphdb',
				java_opts         => ['-DcustomOpt'],
			 }
		  EOS
      end

      it "installs #{graphdb_edition} and one instance with defaults" do
        apply_manifest(manifest, catch_failures: true, debug: ENV['DEBUG'] == 'true')
        expect(apply_manifest(manifest, catch_failures: true, debug: ENV['DEBUG'] == 'true').exit_code).to be_zero
      end

      describe file('/opt/graphdb/instances/test/conf/logback.xml') do
        it { should be_linked_to '/opt/graphdb/dist/conf/logback.xml' }
        it { should be_owned_by 'graphdb' }
        it { should be_grouped_into 'graphdb' }
      end

      describe file('/opt/graphdb/instances/test/conf/tools-logback.xml') do
        it { should be_linked_to '/opt/graphdb/dist/conf/tools-logback.xml' }
        it { should be_owned_by 'graphdb' }
        it { should be_grouped_into 'graphdb' }
      end

      describe file('/opt/graphdb/instances/test') do
        it { should be_directory }
        it { should be_owned_by 'graphdb' }
        it { should be_grouped_into 'graphdb' }
        it { should be_writable.by('owner') }
      end

      describe file('/var/lib/graphdb/test/plugins') do
        it { should be_directory }
        it { should be_owned_by 'graphdb' }
        it { should be_grouped_into 'graphdb' }
        it { should be_writable.by('owner') }
      end

      describe file('/var/tmp/graphdb/test') do
        it { should be_directory }
        it { should be_owned_by 'graphdb' }
        it { should be_grouped_into 'graphdb' }
        it { should be_writable.by('owner') }
      end

      describe file('/opt/graphdb/instances/test/conf') do
        it { should be_directory }
        it { should be_owned_by 'graphdb' }
        it { should be_grouped_into 'graphdb' }
        it { should be_writable.by('owner') }
      end

      describe file('/var/lib/graphdb/test') do
        it { should be_directory }
        it { should be_owned_by 'graphdb' }
        it { should be_grouped_into 'graphdb' }
        it { should be_writable.by('owner') }
      end

      describe file('/var/log/graphdb/test') do
        it { should be_directory }
        it { should be_owned_by 'graphdb' }
        it { should be_grouped_into 'graphdb' }
        it { should be_writable.by('owner') }
      end

      describe service('graphdb-test') do
        it { should be_enabled } unless %w[Debian CentOS].include? fact('operatingsystem')
        it { should be_running }
      end

      describe process('java') do
        its(:user) { should eq 'graphdb' }
        its(:args) { should match /-Dgraphdb.home=\/opt\/graphdb\/instances\/test/ }
        its(:args) { should match /-DcustomOpt/ }
        its(:args) { should match /-Xmx256m/ }
        its(:args) { should match /-Xms256m/ }
        its(:args) { should match /-Dgraphdb.workbench.external-url=http:\/\/test.com\/graphdb/ }
        its(:count) { should eq 1 }
      end

      describe port(8080) do
        it { should be_listening.with('tcp') }
      end

      describe command("curl -f -s -m 30 --connect-timeout 20 -X GET 'http://#{fact('ipaddress')}:8080/protocol'") do
        its(:exit_status) { should eq 0 }
      end

      describe command("curl -f -s -m 30 --connect-timeout 20 -X GET -u :duper 'http://#{fact('ipaddress')}:8080/jolokia/version'") do
        its(:exit_status) { should eq 0 }
        its(:stdout) { should match /"status":200/ }
      end
    end

    context "#{graphdb_edition} installation" do
      let(:manifest) do
        <<-EOS
			 class{ 'graphdb':
			 version              => '#{graphdb_version}',
			 edition              => '#{graphdb_edition}',
			 graphdb_download_url => 'file:///tmp',
			 }

			 graphdb::instance { 'test':
  		 		license           => '/tmp/#{graphdb_edition}.license',
  				jolokia_secret    => 'duper',
  				http_port         => 8080,
				validator_timeout => #{graphdb_timeout},
				heap_size         => '257m',
				java_opts         => ['-DcustomOpt'],
			 }
		  EOS
      end

      it "installs #{graphdb_edition} and one instance with defaults" do
        apply_manifest(manifest, catch_failures: true, debug: ENV['DEBUG'] == 'true')
        expect(apply_manifest(manifest, catch_failures: true, debug: ENV['DEBUG'] == 'true').exit_code).to be_zero
      end

      describe process('java') do
        its(:user) { should eq 'graphdb' }
        its(:args) { should match /-Dgraphdb.home=\/opt\/graphdb\/instances\/test/ }
        its(:args) { should match /-DcustomOpt/ }
        its(:args) { should match /-Xmx257m/ }
        its(:args) { should match /-Xms257m/ }
        its(:count) { should eq 1 }
      end
    end

    context "#{graphdb_edition} uninstall" do
      let(:manifest) do
        <<-EOS
			   class{ 'graphdb':
			     version              => '#{graphdb_version}',
			     edition              => '#{graphdb_edition}',
			     graphdb_download_url => 'file:///tmp',
			   }

			   graphdb::instance { 'test':
			      ensure => 'absent',
			   }
			EOS
      end

      it "keeps #{graphdb_edition} and uninstall the instance" do
        apply_manifest(manifest, catch_failures: true, debug: ENV['DEBUG'] == 'true')
      end

      describe file('/opt/graphdb/instances/test') do
        it { should_not exist }
      end

      describe file('/var/log/graphdb/test') do
        it { should_not exist }
      end

      describe file('/var/lib/graphdb/test') do
        it { should_not exist }
      end

      describe file('/var/tmp/graphdb/test') do
        it { should_not exist }
      end

      describe file('/etc/init/graphdb-test.conf') do
        it { should_not exist }
      end

      describe service('graphdb-test') do
        it { should_not be_enabled } unless %w[Debian CentOS].include? fact('operatingsystem')
        it { should_not be_running }
      end

      describe port(8080) do
        it { should_not be_listening.with('tcp') }
      end
    end
  end
end
