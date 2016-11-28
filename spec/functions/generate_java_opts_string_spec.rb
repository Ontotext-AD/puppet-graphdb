require 'spec_helper'

describe 'generate_java_opts_string', type: :puppet_function do
  context 'with valid array' do
    it do
      input = ['-Xmx1g', '-Dtest="test"', '-Xms512m']
      result = "-Xmx1g \\\n" \
	  "-Dtest=\"test\" \\\n" \
	  '-Xms512m'

      is_expected.to run.with_params(input).and_return(result)
    end
  end

  context 'with not valid array' do
    it do
      input = '-Xmx1g -Dtest -Xms512m'

      is_expected.to run.with_params(input).and_raise_error(ArgumentError, /expected argument to be an Array/)
    end

    it do
      is_expected.to run.with_params.and_raise_error(ArgumentError, /Wrong number of arguments/)
    end
  end
end
