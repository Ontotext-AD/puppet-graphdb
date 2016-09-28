require 'spec_helper_acceptance'

describe 'graphdb::ee::backup_cron', unless: UNSUPPORTED_PLATFORMS.include?(fact('osfamily')) do
  graphdb_version = ENV['GRAPHDB_VERSION']
  graphdb_timeout = ENV['GRAPHDB_TIMEOUT']

  context 'ee installation with master repository and backup cron' do
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

			graphdb::ee::backup_cron { 'backup-test':
				master_endpoint   => "http://${::ipaddress}:8080",
				master_repository => 'master',
				jolokia_secret    => 'duper',
				hour              => '4',
				minute            => '20',
			}
		EOS
    end

    it do
      apply_manifest(manifest, catch_failures: true, debug: ENV['DEBUG'] == 'true')
      expect(apply_manifest(manifest, catch_failures: true).exit_code).to be_zero
    end

    describe file('/opt/graphdb/backup-test') do
      it { should be_file }
      it { should be_owned_by 'graphdb' }
      it { should be_grouped_into 'graphdb' }
      it { should be_executable.by('owner') }
    end

    describe cron do
      it { should have_entry("20 4 * * * /opt/graphdb/backup-test http://#{fact('ipaddress')}:8080 master duper >> /opt/graphdb/backup-test.log 2>&1").with_user('graphdb') }
    end

    describe command("/opt/graphdb/backup-test http://#{fact('ipaddress')}:8080 master duper") do
      its(:exit_status) { should eq 0 }
    end

    describe file('/var/lib/graphdb/master/repositories/master/backup') do
      it { should be_directory }
    end

    describe command("/opt/graphdb/backup-test http://#{fact('ipaddress')}:8080 master duper test-id") do
      its(:exit_status) { should eq 0 }
    end

    describe file('/var/lib/graphdb/master/repositories/master/backup/test-id') do
      it { should be_directory }
    end
  end
end
