# frozen_string_literal: true

require 'spec_helper'
require 'puppet/util/file_utils'

# FileUtils tests
describe '#file_utils' do
  describe 'valid paths' do
    %w(
      C:/
      C:\\
      C:\\WINDOWS\\System32
      C:/windows/system32
      X:/foo/bar
      X:\\foo\\bar
      //host/windows
      /
      /var/tmp
      /var/opt/../lib/puppet
    ).each do |path|
      it "should return true on absolute path: #{path}" do
        expect(Puppet::Util::FileUtils.absolute_path?(path)).to be true
      end
    end
  end

  describe 'invalid paths' do
    [
      nil,
      [nil],
      [nil, nil],
      { 'foo' => 'bar' },
      {},
      ''
    ].each do |path|
      it "should return false on invalid path: #{path}" do
        expect(Puppet::Util::FileUtils.absolute_path?(path)).to be false
      end
    end
  end

  describe 'relative paths' do
    %w(
      relative1
      .
      ..
      ./foo
      ../foo
      etc/puppetlabs/puppet
      opt/puppet/bin
      relative\\windows
    ).each do |path|
      it "should return false on relative path: #{path}" do
        expect(Puppet::Util::FileUtils.absolute_path?(path)).to be false
      end
    end
  end
end
