require_relative 'test_helper'

include Ducktape

class Names
  include Bindable

  bindable :names, default: Ducktape.hookable([])
end

class SimpleBindable
  include Bindable

  bindable :name
end

src = Names.new
src.names.push :a, :b, :c
tgt = SimpleBindable.new
tgt.name = BindingSource.new(src, 'names[0]')
src.names[0] = :d

puts tgt.name == :d