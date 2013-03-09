module Ducktape
  module Expression
    module BinaryOpExp
      attr_reader :left, :right
      attr_reader :owner

      def initialize(left, right)
        @left, @right = left, right
      end

      def owner=(o)
        @owner, left.owner, right.owner = [o]*3
      end

      def bind(src, type, qual = nil, root = src)
        unbind
        lsrc = left.bind(src, :path, qual, root)
        right.bind(lsrc, type, self.class, root)
      end

      def unbind
        left.unbind
        right.unbind
        nil
      end

      def rightmost
        @right.rightmost
      end

      def unparse
        "#{left.unparse}#{self.class.instance_variable_get(:@op)}#{right.unparse}"
      end

      def value
        right.value
      end

      def value=(v)
        right.value = v
      end
    end
  end
end