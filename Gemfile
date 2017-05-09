# This file is generated by ModuleSync, do not edit.

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

gem 'facter', *location_for(ENV['FACTER_GEM_VERSION']) if ENV['FACTER_GEM_VERSION']
gem 'hiera', *location_for(ENV['HIERA_GEM_VERSION']) if ENV['HIERA_GEM_VERSION']

ruby_version_segments = Gem::Version.new(RUBY_VERSION.dup).segments
minor_version = "#{ruby_version_segments[0]}.#{ruby_version_segments[1]}"

group :development, :unit_tests do
  gem 'metadata-json-lint'
  gem 'puppet_facts'
  gem 'puppet-blacksmith', '>= 3.4.0'
  gem 'puppetlabs_spec_helper', '>= 1.2.1'
  gem 'rspec-puppet', '>= 2.3.2'
  gem 'rspec-puppet-facts'
  gem 'rspec-puppet-utils'
  gem 'rspec-mocks'
  gem 'rubocop', '0.41.2' if RUBY_VERSION < '2.0.0'
  gem 'rubocop' if RUBY_VERSION >= '2.0.0'
  gem 'rubocop-rspec', '~> 1.6' if RUBY_VERSION >= '2.3.0'
  gem 'json_pure', '<= 2.0.1' if RUBY_VERSION < '2.0.0'
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

eval(File.read("#{__FILE__}.local"), binding) if File.exist? "#{__FILE__}.local"
