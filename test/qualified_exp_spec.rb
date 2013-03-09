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

describe Expression::QualifiedExp do
  before :all do
    @y = Y.new
  end

  it 'should have equal names' do
    x = NS::M::X.new
    @y.name = BindingSource.new(x.ns, 'M::X.name')
    NS::M::X.name = 'abc'
    @y.name.should == 'abc'
  end
end