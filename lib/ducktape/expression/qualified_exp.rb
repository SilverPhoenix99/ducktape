module Ducktape
  module Expression
    class QualifiedExp #A::B
      include BinaryOpExp
      @op = '::'
    end
  end
end