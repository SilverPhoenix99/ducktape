module Ducktape
  module Expression
    module LiteralExp
      attr_reader :literal
      attr_accessor :owner

      def initialize(literal)
        @literal = literal
        @literal.freeze
      end

      def bind(_, _) end
      def unbind; end

      def rightmost
        nil
      end

      def unparse
        literal.inspect
      end
    end

    class IntegerExp
      include LiteralExp
    end

    class SymbolExp
      include LiteralExp
    end
  end
end