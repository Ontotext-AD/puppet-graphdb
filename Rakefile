require 'rubygems'
require 'puppetlabs_spec_helper/rake_tasks'
require 'net/http'
require 'uri'
require 'fileutils'
require 'rspec/core/rake_task'
require 'guard'
require 'guard/commander'
require 'parallel_tests/tasks'

exclude_paths = [
  'pkg/**/*',
  'vendor/**/*',
  'spec/**/*'
]

require 'puppet-doc-lint/rake_task'
PuppetDocLint.configuration.ignore_paths = exclude_paths

require 'puppet-lint/tasks/puppet-lint'
require 'puppet-syntax/tasks/puppet-syntax'

PuppetSyntax.exclude_paths = exclude_paths
PuppetSyntax.future_parser = true if ENV['FUTURE_PARSER'] == 'true'

%w(
  80chars
  class_inherits_from_params_class
  class_parameter_defaults
  documentation
  single_quote_string_with_variables
).each do |check|
  PuppetLint.configuration.send("disable_#{check}")
end

PuppetLint.configuration.ignore_paths = exclude_paths
PuppetLint.configuration.log_format = '%{path}:%{linenumber}:%{check}:%{KIND}:%{message}'

RSpec::Core::RakeTask.new(:spec_verbose) do |t|
  t.pattern = 'spec/{classes,defines,unit,functions}/**/*_spec.rb'
  t.rspec_opts = [
    '--format documentation',
    '--require "ci/reporter/rspec"',
    '--format CI::Reporter::RSpecFormatter',
    '--color'
  ]
end
task spec_verbose: :spec_prep

task beaker: [:spec_prep, 'artifacts:prep']
