require 'spec_helper_acceptance'

describe 'graphdb::data', unless: UNSUPPORTED_PLATFORMS.include?(fact('osfamily')) do
  graphdb_version = ENV['GRAPHDB_VERSION']
  graphdb_timeout = ENV['GRAPHDB_TIMEOUT']

  context 'se installation with se repository and one data from archive' do
    let(:manifest) do
      <<-EOS
			 class{ 'graphdb':
			    version              => '#{graphdb_version}',
			    edition              => 'se',
				graphdb_download_url => 'file:///tmp',
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

			 graphdb::data{ 'data-zip':
			  repository          => 'test-repo',
			  endpoint            => "http://${::ipaddress}:8080",
			  archive             => 'puppet:///modules/test/test.ttl.zip',
			  exists_query        =>  'ask { <http://test> ?p ?o . } ',
			 }
		  EOS
    end

    it do
      apply_manifest(manifest, catch_failures: true, debug: ENV['DEBUG'] == 'true')
      expect(apply_manifest(manifest, catch_failures: true, debug: ENV['DEBUG'] == 'true').exit_code).to be_zero
    end

    describe command("curl -f -s -m 30 --connect-timeout 20 -H 'Accept: text/boolean' -X GET 'http://#{fact('ipaddress')}:8080/repositories/test-repo?query=ask%20%7B%20%3Chttp%3A%2F%2Ftest%3E%20a%20%3Chttp%3A%2F%2Ftest.com%2Fontologies%2Ftest%23good%3E%20.%20%7D%20'") do
      its(:exit_status) { should eq 0 }
      its(:stdout) { should eq 'true' }
    end
  end
end
