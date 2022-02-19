source ENV['GEM_SOURCE'] || 'https://rubygems.org'

# Find a location or specific version for a gem. place_or_version can be a
# version, which is most often used. It can also be git, which is specified as
# `git://somewhere.git#branch`. You can also use a file source location, which
# is specified as `file://some/location/on/disk`.
def location_for(place_or_version, fake_version = nil)
  if place_or_version =~ /^(git[:@][^#]*)#(.*)/
    [fake_version, { :git => $1, :branch => $2, :require => false }].compact
  elsif place_or_version =~ /^file:\/\/(.*)/
    ['>= 0', { :path => File.expand_path($1), :require => false }]
  else
    [place_or_version, { :require => false }]
  end
end

gem 'rake', require: false
gem 'facter', ENV['FACTER_GEM_VERSION'], require: false, groups: [:test]

group :development, :unit_tests do
  gem 'metadata-json-lint'
  gem 'puppet_facts'
  gem 'puppet-blacksmith', '>= 3.4.0'
  gem 'puppetlabs_spec_helper', '>= 1.2.1'
  gem 'rspec-puppet', '>= 2.3.2'
  gem 'rspec-puppet-facts'
  gem 'rspec-puppet-utils'
  gem 'rspec-mocks'
  gem 'rubocop'
  gem 'rubocop-rspec', '~> 1.6'
  gem 'guard'
  gem 'guard-rspec', require: false
  gem 'guard-rubocop'
  gem 'pry-doc'
  gem 'webmock'
  gem 'parallel_tests'
  gem 'simplecov', require: false
  gem 'rspec_junit_formatter'
end

group :system_tests do
  gem 'beaker', *location_for(ENV['BEAKER_VERSION'] || '>= 3')
  gem 'beaker-rspec', *location_for(ENV['BEAKER_RSPEC_VERSION'])
  gem 'serverspec'
  gem 'beaker-puppet_install_helper'
  gem 'master_manipulator'
  gem "beaker-hostgenerator", *location_for(ENV['BEAKER_HOSTGENERATOR_VERSION'])
  gem 'rspec_junit_formatter'
end

puppetversion = ENV['PUPPET_VERSION'] || '>= 6.0'
gem 'puppet', puppetversion, require: false, groups: [:test]

# vim: syntax=ruby
