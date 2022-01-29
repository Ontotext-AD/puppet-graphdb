# frozen_string_literal: true

# Fact: graphdb_java_home
#
# Purpose: get absolute path of java system home
#
# Resolution:
#   Find the real java binary, and return the subsubdir
#
# Caveats:
#   java binary has to be found in $PATH
#
# Notes:
#   SPEC : let(:graphdb_java_home) { '/opt/jdk8' }
Facter.add(:graphdb_java_home) do
  confine kernel: ['Linux', 'OpenBSD']
  graphdb_java_home = nil
  setcode do
    java_bin = Facter::Util::Resolution.which('java').to_s.strip
    if java_bin.empty?
      nil
    else
      java_path = File.realpath(java_bin)
      graphdb_java_home = if %r{/jre/}.match?(java_path)
                            File.dirname(File.dirname(File.dirname(java_path)))
                          else
                            File.dirname(File.dirname(java_path))
                          end
    end
  end
  graphdb_java_home
end
