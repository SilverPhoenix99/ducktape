require_relative 'test_helper'
require_relative '../lib/ducktape/bindable'

RSpec.describe Ducktape::Bindable do

  # noinspection RubyConstantNamingConvention
  Bindable = Ducktape::Bindable

  let(:subject_class) do
    Class.new do
      include Bindable

      bindable :x,
               default: 1,
               validate: [nil, Integer],
               getter: ->(v) { v&.+(100) },
               setter: ->(v) { v.to_i }
    end
  end

  subject { subject_class.new }

  describe '::' do

    it '' do
      fail
    end

  end

end
