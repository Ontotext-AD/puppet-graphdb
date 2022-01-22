# frozen_string_literal: true

module Puppet
  module Util
    # File operation related utils
    class FileUtils
      @slash = '[\\\\/]'
      @name = '[^\\\\/]+'
      @regexes = {
        windows: Regexp.new(/^(([A-Z]:#{@slash})|(#{@slash}#{@slash}#{@name}#{@slash}#{@name})
        |(#{@slash}#{@slash}\?#{@slash}#{@name}))/i),
        posix: Regexp.new(%r{^/})
      }.freeze

      def self.absolute_path?(path)
        begin
          return true if (@regexes[:posix] =~ path) || (@regexes[:windows] =~ path)
        rescue TypeError
          false
        end
        false
      end
    end
  end
end
