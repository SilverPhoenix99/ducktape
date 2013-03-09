require_relative 'test_helper'

include Ducktape

class Names
  include Bindable

  bindable :names, default: ->() { Ducktape.hookable([]) }
end

class SimpleBindable
  include Bindable

  bindable :name
end

describe Expression::IndexerExp do
  it 'should have the same name' do
    src = Names.new
    src.names.push :a, :b, :c
    tgt = SimpleBindable.new

    tgt.name = BindingSource.new(src, 'names[0]')

    tgt.name.should == :a
  end

  it 'should have update the name' do
    src = Names.new
    src.names.push :a, :b, :c
    tgt = SimpleBindable.new
    tgt.name = BindingSource.new(src, 'names[0]')
    src.names[0] = :d

    tgt.name.should == :d
  end
end