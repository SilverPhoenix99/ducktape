require_relative 'test_helper'

include Ducktape

module NS
  module M
    class X
      class << self
        include Bindable
        bindable :name
      end

      def ns
        ::NS
      end
    end
  end
end

class Y
  include Bindable
  bindable :name
end

RSpec.instance_eval do

  describe Expression::QualifiedExp do
    let(:y) { Y.new }

    subject { y }

    it 'should have equal names' do
      x = NS::M::X.new
      y.bind :name, x.ns, 'M::X.name'
      NS::M::X.name = 'abc'
      should have_attributes(name: 'abc')
    end
  end

end
