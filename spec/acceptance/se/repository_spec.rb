require 'spec_helper_acceptance'

describe 'graphdb::se::repository', unless: UNSUPPORTED_PLATFORMS.include?(fact('osfamily')) do
  graphdb_version = ENV['GRAPHDB_VERSION']
  graphdb_timeout = ENV['GRAPHDB_TIMEOUT']

  context 'se installation with se repository' do
    let(:manifest) do
      <<-EOS
			 class{ 'graphdb':
			 version   => '#{graphdb_version}',
			 edition   => 'se',
			 }

			 graphdb::instance { 'test':
  		 		license           => '/tmp/se.license',
  				jolokia_secret    => 'duper',
  				http_port         => 8080,
				validator_timeout => #{graphdb_timeout},
			 }

		     graphdb::se::repository { 'test-repo':
		        repository_id       => 'test-repo',
		    	endpoint            => "http://${::ipaddress}:8080",
		    	repository_context  => 'http://ontotext.com/pub/',
				timeout             => #{graphdb_timeout},
		  	 }
		  EOS
    end

    it do
      apply_manifest(manifest, catch_failures: true, debug: true)
      expect(apply_manifest(manifest, catch_failures: true).exit_code).to be_zero
    end

    describe command("curl -f -s -X GET 'http://#{fact('ipaddress')}:8080/repositories/test-repo/size'") do
      its(:exit_status) { should eq 0 }
    end
  end
end
