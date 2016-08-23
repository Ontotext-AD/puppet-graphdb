module Puppet
  module Util
    class FileUtils
      @@SLASH = '[\\\\/]'.freeze
      @@NAME = '[^\\\\/]+'.freeze
      @@REGEXES = {
        windows: /^(([A-Z]:#{@@SLASH})|(#{@@SLASH}#{@@SLASH}#{@@NAME}#{@@SLASH}#{@@NAME})|(#{@@SLASH}#{@@SLASH}\?#{@@SLASH}#{@@NAME}))/i,
        posix: %r{^/}
      }.freeze

      def self.is_absolute_path(path)
        !!(path =~ @@REGEXES[:posix]) || !!(path =~ @@REGEXES[:windows])
      end
    end
  end
end
