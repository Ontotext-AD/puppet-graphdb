# frozen_string_literal: true

# put local configuration and setup into spec_helper_local
begin
  require 'spec_helper_local'
rescue LoadError
end
