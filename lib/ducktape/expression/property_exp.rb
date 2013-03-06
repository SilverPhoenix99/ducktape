module Ducktape
  module Expression
    class PropertyExp #a.b
      include BinaryOpExp
      @op = '.'
    end
  end
end