require_relative 'test_helper'

include Ducktape

RSpec.instance_eval do

  describe Expression::QualifiedExp do

    let(:NS) do
      Module.new.tap do |ns|
        module ns::M
          class X
            class << self
              include Bindable
              bindable :name
            end
          end
        end
      end
    end

    let(:Y) do
      Class.new do
        include Bindable
        bindable :name
      end
    end

    subject { Y().new }

    it 'should have equal names' do
      subject.bind :name, NS(), 'M::X.name'
      NS()::M::X.name = 'abc'
      should have_attributes(name: 'abc')
    end
  end

end
