require_relative '../lib/ducktape'

require 'rspec/expectations'

RSpec.configure do |config|
  config.expose_dsl_globally = false

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_doubled_constant_names = true
    mocks.verify_partial_doubles = true
  end
end

RSpec::Matchers.define :have_instance_method do |expected|
  match { |actual| actual.method_defined?(expected) }
end
