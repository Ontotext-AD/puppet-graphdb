require 'spec_helper_acceptance'

describe 'graphdb::instance', unless: UNSUPPORTED_PLATFORMS.include?(fact('osfamily')) do
  graphdb_version = ENV['GRAPHDB_VERSION']
  graphdb_timeout = ENV['GRAPHDB_TIMEOUT']

  %w(ee se).each do |graphdb_edition|
    context "#{graphdb_edition} installation" do
      let(:manifest) do
        <<-EOS
			 class{ 'graphdb':
			 version   => '#{graphdb_version}',
			 edition   => '#{graphdb_edition}',
			 }

			 graphdb::instance { 'test':
  		 		license           => '/tmp/#{graphdb_edition}.license',
  				jolokia_secret    => 'duper',
  				http_port         => 8080,
				validator_timeout => #{graphdb_timeout},
			 }
		  EOS
      end

      it "installs #{graphdb_edition} and one instance with defaults" do
        apply_manifest(manifest, catch_failures: true, debug: true)
        expect(apply_manifest(manifest, catch_failures: true).exit_code).to be_zero
      end

      describe service('graphdb-test') do
        it { should be_enabled } unless %w(Debian CentOS).include? fact('operatingsystem')
        it { should be_running }
      end

      describe process('java') do
        its(:user) { should eq 'graphdb' }
        its(:args) { should match /-Dgraphdb.home=\/opt\/graphdb\/instances\/test/ }
        its(:count) { should eq 1 }
      end

      describe port(8080) do
        it { should be_listening.with('tcp') }
      end

      describe command("curl -f -s -X GET 'http://#{fact('ipaddress')}:8080/protocol'") do
        its(:exit_status) { should eq 0 }
      end

      describe command("curl -f -s -X GET -u :duper 'http://#{fact('ipaddress')}:8080/jolokia/version'") do
        its(:exit_status) { should eq 0 }
        its(:stdout) { should match /"status":200/ }
      end
    end
  end
end
