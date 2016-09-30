require 'spec_helper_acceptance'

describe 'graphdb::graphdb_link', unless: UNSUPPORTED_PLATFORMS.include?(fact('osfamily')) do
  graphdb_version = ENV['GRAPHDB_VERSION']
  graphdb_timeout = ENV['GRAPHDB_TIMEOUT']

  context 'ee installation with master-worker link' do
    let(:manifest) do
      <<-EOS
			 class{ 'graphdb':
			 	version              => '#{graphdb_version}',
			 	edition              => 'ee',
				graphdb_download_url => 'file:///tmp',
			 }

			 graphdb::instance { 'master':
  		 		license           => '/tmp/ee.license',
  				jolokia_secret    => 'duper',
  				http_port         => 8080,
				validator_timeout => #{graphdb_timeout},
			 }

		     graphdb::ee::master::repository { 'master':
		        repository_id       => 'master',
		    	endpoint            => "http://${::ipaddress}:8080",
		    	repository_context  => 'http://ontotext.com/pub/',
				timeout             => #{graphdb_timeout},
		  	 }

			 graphdb::instance { 'worker':
				license           => '/tmp/ee.license',
				http_port         => 9090,
				validator_timeout => #{graphdb_timeout},
			 }

			 graphdb::ee::worker::repository { 'worker':
				repository_id       => 'worker',
				endpoint            => "http://${::ipaddress}:9090",
				repository_context  => 'http://ontotext.com/pub/',
				timeout             => #{graphdb_timeout},
			 }

			 graphdb_link { 'master-worker':
			 	master_repository_id => 'master',
			 	master_endpoint      => "http://${::ipaddress}:8080",
			 	worker_repository_id => 'worker',
			 	worker_endpoint      => "http://${::ipaddress}:9090",
			}
		EOS
    end

    it do
      apply_manifest(manifest, catch_failures: true, debug: ENV['DEBUG'] == 'true')
      expect(apply_manifest(manifest, catch_failures: true).exit_code).to be_zero
    end

    describe command("curl -f -m 30 --connect-timeout 20 -X GET -u ':duper' 'http://#{fact('ipaddress')}:8080/jolokia/read/ReplicationCluster:name=ClusterInfo!/master/NodeStatus'") do
      its(:exit_status) { should eq 0 }
      regex = Regexp.escape("\"value\":[\"[ON] http://#{fact('ipaddress')}:9090/repositories/worker\"]".gsub('/', '\/'))
      its(:stdout) { should match regex }
    end
  end

  context 'ee installation with master-worker unlink' do
    let(:manifest) do
      <<-EOS
		   class{ 'graphdb':
			  version              => '#{graphdb_version}',
			  edition              => 'ee',
			  graphdb_download_url => 'file:///tmp',
		   }

		   graphdb::instance { 'master':
				  license           => '/tmp/ee.license',
				  jolokia_secret    => 'duper',
				  http_port         => 8080,
			  validator_timeout => #{graphdb_timeout},
		   }

		   graphdb::ee::master::repository { 'master':
			  repository_id       => 'master',
			  endpoint            => "http://${::ipaddress}:8080",
			  repository_context  => 'http://ontotext.com/pub/',
			  timeout             => #{graphdb_timeout},
		   }

		   graphdb::instance { 'worker':
			  license           => '/tmp/ee.license',
			  http_port         => 9090,
			  validator_timeout => #{graphdb_timeout},
		   }

		   graphdb::ee::worker::repository { 'worker':
			  repository_id       => 'worker',
			  endpoint            => "http://${::ipaddress}:9090",
			  repository_context  => 'http://ontotext.com/pub/',
			  timeout             => #{graphdb_timeout},
		   }

		   graphdb_link { 'master-worker':
              ensure               => 'absent',
			  master_repository_id => 'master',
			  master_endpoint      => "http://${::ipaddress}:8080",
			  worker_repository_id => 'worker',
			  worker_endpoint      => "http://${::ipaddress}:9090",
		  }
	  EOS
    end

    it do
      apply_manifest(manifest, catch_failures: true, debug: ENV['DEBUG'] == 'true')
      expect(apply_manifest(manifest, catch_failures: true, debug: ENV['DEBUG'] == 'true').exit_code).to be_zero
    end

    describe command("curl -f -m 30 --connect-timeout 20 -X GET -u ':duper' 'http://#{fact('ipaddress')}:8080/jolokia/read/ReplicationCluster:name=ClusterInfo!/master/NodeStatus'") do
      its(:exit_status) { should eq 0 }
      regex = Regexp.escape('"value":[]'.gsub('/', '\/'))
      its(:stdout) { should match regex }
    end
  end
end
