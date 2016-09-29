require 'spec_helper_acceptance'

describe 'graphdb::instance', unless: UNSUPPORTED_PLATFORMS.include?(fact('osfamily')) do
  graphdb_version = ENV['GRAPHDB_VERSION']

  %w(ee se).each do |graphdb_edition|
    context "#{graphdb_edition} installation" do
      let(:manifest) do
        <<-EOS
			 class{ 'graphdb':
			 version              => '#{graphdb_version}',
			 edition              => '#{graphdb_edition}',
			 graphdb_download_url => 'file:///tmp',
			 }
		  EOS
      end

      it "installs #{graphdb_edition} with defaults" do
        apply_manifest(manifest, catch_failures: true, debug: ENV['DEBUG'] == 'true')
        expect(apply_manifest(manifest, catch_failures: true, debug: ENV['DEBUG'] == 'true').exit_code).to be_zero
      end

      describe command('/opt/graphdb/dist/bin/graphdb -v') do
        its(:stdout) { should contain(graphdb_version) }
        expected_edition = if graphdb_edition == 'ee'
                             'GRAPHDB_ENTERPRISE'
                           else
                             'GRAPHDB_SE'
                           end
        its(:stdout) { should contain(expected_edition) }
      end

      describe user('graphdb') do
        it { should exist }
      end

      describe user('graphdb') do
        it { should belong_to_group 'graphdb' }
      end

      describe file('/opt/graphdb/dist/bin') do
        it { should be_directory }
        it { should be_owned_by 'graphdb' }
        it { should be_grouped_into 'graphdb' }
        it { should be_writable.by('owner') }
      end

      describe file('/opt/graphdb/instances') do
        it { should be_directory }
        it { should be_owned_by 'graphdb' }
        it { should be_grouped_into 'graphdb' }
        it { should be_writable.by('owner') }
      end

      describe file('/var/tmp/graphdb') do
        it { should be_directory }
        it { should be_owned_by 'graphdb' }
        it { should be_grouped_into 'graphdb' }
        it { should be_writable.by('owner') }
      end

      describe file('/var/lib/graphdb') do
        it { should be_directory }
        it { should be_owned_by 'graphdb' }
        it { should be_grouped_into 'graphdb' }
        it { should be_writable.by('owner') }
      end

      describe file('/bin/console') do
        it { should be_linked_to '/opt/graphdb/dist/bin/console' }
        it { should be_executable }
      end

      describe file('/bin/loadrdf') do
        it { should be_linked_to '/opt/graphdb/dist/bin/loadrdf' }
        it { should be_executable }
      end

      describe file('/bin/migration-wizard') do
        it { should be_linked_to '/opt/graphdb/dist/bin/migration-wizard' }
        it { should be_executable }
      end

      describe file('/bin/rdfvalidator') do
        it { should be_linked_to '/opt/graphdb/dist/bin/rdfvalidator' }
        it { should be_executable }
      end

      describe file('/bin/report') do
        it { should be_linked_to '/opt/graphdb/dist/bin/report' }
        it { should be_executable }
      end

      describe file('/bin/rule-compiler') do
        it { should be_linked_to '/opt/graphdb/dist/bin/rule-compiler' }
        it { should be_executable }
      end

      describe file('/bin/storage-tool') do
        it { should be_linked_to '/opt/graphdb/dist/bin/storage-tool' }
        it { should be_executable }
      end
    end

    context "#{graphdb_edition} uninstallation" do
      let(:manifest) do
        <<-EOS
			   class { 'graphdb':
			     ensure  => 'absent',
			     version => '#{graphdb_version}',
			     edition => '#{graphdb_edition}',
			   }
			EOS
      end

      it "uninstalls #{graphdb_edition}" do
        apply_manifest(manifest, catch_failures: true, debug: ENV['DEBUG'] == 'true')
        expect(apply_manifest(manifest, catch_failures: true, debug: ENV['DEBUG'] == 'true').exit_code).to be_zero
      end

      describe user('graphdb') do
        it { should_not exist }
      end

      describe file('/opt/graphdb') do
        it { should_not exist }
      end

      describe file('/var/tmp/graphdb') do
        it { should_not exist }
      end

      describe file('/var/log/graphdb') do
        it { should_not exist }
      end

      describe file('/bin/console') do
        it { should_not exist }
      end

      describe file('/bin/loadrdf') do
        it { should_not exist }
      end

      describe file('/bin/migration-wizard') do
        it { should_not exist }
      end

      describe file('/bin/rdfvalidator') do
        it { should_not exist }
      end

      describe file('/bin/report') do
        it { should_not exist }
      end

      describe file('/bin/rule-compiler') do
        it { should_not exist }
      end

      describe file('/bin/storage-tool') do
        it { should_not exist }
      end
    end
  end
end
