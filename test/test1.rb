require_relative 'test_helper'

class X
  class << self
    include Ducktape::Bindable
    bindable :x, default: :a
  end
end

class Y
  include Ducktape::Bindable
  bindable :y, default: :b
end

p X.x
p Y.new.y