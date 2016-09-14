require 'puppetlabs_spec_helper/module_spec_helper'
require 'rspec-puppet-facts'
require 'spec_helper'

include RspecPuppetFacts

if ENV['COVERAGE']
  require 'simplecov'
  SimpleCov.start do
    add_filter '.vendor'

    add_group 'module library', 'lib/puppet'
    add_group 'module utils', 'lib/puppet/util'
    add_group 'module type', 'lib/puppet/type'
    add_group 'module provider', 'lib/puppet/provider'

    # add_group 'library', '.vendor'
  end
end

def fixture_path
  File.expand_path(File.join(__FILE__, '..', 'fixtures'))
end

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', '..', '..'))

RSpec.configure do |config|
  config.add_setting(:fixture_path, default: fixture_path)
  config.mock_with(:rspec)
  config.hiera_config = File.join(fixture_path, '/hiera/hiera.yaml')
  config.color = true
  config.tty = true
  config.formatter = :documentation
end
