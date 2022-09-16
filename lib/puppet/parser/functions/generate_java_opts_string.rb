# frozen_string_literal: true

#
# generate_java_opts_string.rb
#

module Puppet::Parser::Functions
  newfunction(:generate_java_opts_string, type: :rvalue, doc: <<-EOS
This function java opts string from given array.

*Examples:*

    generate_java_opts_string(['-Xmx1g','-Xms2g','-Dwell'])

Will return: "-Xmx1g \
        -Xms2g \
        -Dwell"
        EOS
      ) do |arguments|

    raise(ArgumentError, 'generate_java_opts_string(): Wrong number of arguments ' \
      "given (#{arguments.size} for 1)") if arguments.empty?

    array = arguments[0]

    unless array.is_a?(Array)
      raise ArgumentError, "generate_java_opts_string(): expected argument to be an Array, got #{array.inspect}"
    end

    array[0...-1].map { |opt| opt.insert(-1, ' \\') }
    return array.join("\n").to_s
  end
end
