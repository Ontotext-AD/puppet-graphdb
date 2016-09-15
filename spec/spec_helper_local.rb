require 'puppetlabs_spec_helper/module_spec_helper'
require 'rspec-puppet-facts'

include RspecPuppetFacts

if ENV['COVERAGE']
  require 'simplecov'
  SimpleCov.start do
    add_filter '.vendor'

    add_group 'module library', 'lib/puppet'
    add_group 'module utils', 'lib/puppet/util'
    add_group 'module type', 'lib/puppet/type'
    add_group 'module provider', 'lib/puppet/provider'
  end
end

RSpec.configure do |config|
  config.before :each do
    # Ensure that we don't accidentally cache facts and environment
    # between test cases.
    Facter::Util::Loader.any_instance.stubs(:load_all)
    Facter.clear
    Facter.clear_messages

    # Store any environment variables away to be restored later
    @old_env = {}
    ENV.each_key { |k| @old_env[k] = ENV[k] }

    Puppet.settings[:strict_variables] = true if ENV['STRICT_VARIABLES'] == 'yes'
  end
end

RSpec.configure do |config|
  config.filter_run focus: true
  config.run_all_when_everything_filtered = true
  config.mock_with(:rspec)
  config.include PuppetlabsSpec::Files
  config.after :each do
    PuppetlabsSpec::Files.cleanup
  end
end

shared_examples :compile, compile: true do
  it { should compile.with_all_deps }
end

shared_examples 'a mod class, without including apache' do
  let :facts do
    {
      id: 'root',
      lsbdistcodename: 'squeeze',
      kernel: 'Linux',
      osfamily: 'Debian',
      operatingsystem: 'Debian',
      operatingsystemrelease: '6',
      operatingsystemmajrelease: nil,
      path: '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
      concat_basedir: '/dne',
      is_pe: false,
      hardwaremodel: 'x86_64'
    }
  end
  it { should compile.with_all_deps }
end
