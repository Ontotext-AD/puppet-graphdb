require 'beaker-rspec/spec_helper'
require 'beaker-rspec/helpers/serverspec'
require 'beaker/puppet_install_helper'
require 'beaker/dsl/helpers'

puppet_version = ENV['PUPPET_VERSION']

block_on hosts do |host|
  if host['platform'] =~ /ubuntu-(16.04)/
    # Workaround https://tickets.puppetlabs.com/browse/BKR-821
    install_puppetlabs_release_repo(host, repo = 'pc1', opts = { release_apt_repo_url: 'http://apt.puppetlabs.com/' })

    host.install_package("puppet-common=#{puppet_version}-2ubuntu0.1")
    host.install_package("puppet=#{puppet_version}-2ubuntu0.1")
    configure_type_defaults_on(host)
  else
    install_puppet_on(host, version: puppet_version, puppet_agent_version: '1.1.0', default_action: 'gem_install')
  end
end

UNSUPPORTED_PLATFORMS = %w[AIX windows Solaris Suse].freeze
graphdb_version = ENV['GRAPHDB_VERSION']

RSpec.configure do |c|
  # Project root
  proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))

  # Readable test descriptions
  c.formatter = :documentation

  c.before(:all) do
    hosts.each do |host|
      on(host, 'crontab -r -u graphdb', accept_all_exit_codes: true)
      on(host, 'service graphdb-test stop', accept_all_exit_codes: true)
      on(host, 'service graphdb-master stop', accept_all_exit_codes: true)
      on(host, 'service graphdb-worker stop', accept_all_exit_codes: true)

      on(host, 'rm -f /etc/init/graphdb-*', acceptable_exit_codes: [0])
      on(host, 'rm -f /etc/init.d/graphdb-*', acceptable_exit_codes: [0])
      on(host, 'rm -f /lib/systemd/system/graphdb-*', acceptable_exit_codes: [0])
      on(host, '/bin/systemctl daemon-reload', accept_all_exit_codes: true)
      on(host, 'killall -9 java', accept_all_exit_codes: true)
      on(host, 'rm -rf /opt/graphdb/instances', acceptable_exit_codes: [0])
      on(host, 'rm -rf /var/lib/graphdb', acceptable_exit_codes: [0])
      # on(host, 'rm -rf /var/tmp/graphdb', acceptable_exit_codes: [0])
      on(host, 'rm -f /var/log/upstart/graphdb*', acceptable_exit_codes: [0])
    end
  end

  # Configure all nodes in nodeset
  c.before :suite do
    hosts.each do |host|
      on(host, "mkdir -p /tmp/graphdb-se/#{graphdb_version}")
      on(host, "mkdir -p /tmp/graphdb-ee/#{graphdb_version}")
      on(host, "curl --insecure --keepalive-time 700 -o /tmp/graphdb-se/#{graphdb_version}/graphdb-se-#{graphdb_version}-dist.zip http://maven.ontotext.com/content/groups/all-onto/com/ontotext/graphdb/graphdb-se/#{graphdb_version}/graphdb-se-#{graphdb_version}-dist.zip", acceptable_exit_codes: [0])
      on(host, "curl --insecure --keepalive-time 700 -o /tmp/graphdb-ee/#{graphdb_version}/graphdb-ee-#{graphdb_version}-dist.zip http://maven.ontotext.com/content/groups/all-onto/com/ontotext/graphdb/graphdb-ee/#{graphdb_version}/graphdb-ee-#{graphdb_version}-dist.zip", acceptable_exit_codes: [0])

      if on(host, 'ls /tmp/jdk-8u102-linux-x64.tar.gz', accept_all_exit_codes: true).exit_code.nonzero?
        on(host, 'curl -j -k -L -H "Cookie: oraclelicense=accept-securebackup-cookie" '\
            'http://download.oracle.com/otn-pub/java/jdk/8u102-b14/jdk-8u102-linux-x64.tar.gz >'\
            ' /tmp/jdk-8u102-linux-x64.tar.gz', acceptable_exit_codes: [0])
      end

      if on(host, 'ls /tmp/jdk1.8.0_102', accept_all_exit_codes: true).exit_code.nonzero?
        on(host, 'tar -zxf /tmp/jdk-8u102-linux-x64.tar.gz -C /tmp', acceptable_exit_codes: [0])
      end

      host.add_env_var('JAVA_HOME', '/tmp/jdk1.8.0_102')

      scp_to(host, 'ee.license', '/tmp/ee.license')
      scp_to(host, 'se.license', '/tmp/se.license')
      scp_to(host, 'spec/fixtures/test.ttl', '/tmp/test.ttl')

      # Install module and dependencies
      puppet_module_install(source: proj_root, module_name: 'graphdb')
      puppet_module_install(source: "#{proj_root}/spec/fixtures/modules/test", module_name: 'test')

      on host, puppet('module', 'install', 'puppetlabs-stdlib'), acceptable_exit_codes: [0, 1]
    end
  end
end
