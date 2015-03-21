require_relative '../lib/ducktape'

require 'rspec/expectations'

RSpec::Matchers.define :have_instance_method do |expected|
  match { |actual| actual.method_defined?(expected) }
end