module Ducktape
  module Expression
    class IndexerExp # left[right+]
      include BinaryOpExp
      include Ref

      alias_method :params, :right

      def bind(src, type, qual = nil, root = src)
        unbind
        @source = WeakReference.new(left.bind(src, :path, qual, root))
        @type = type
        params.each { |param| param.bind(root, :path) }

        src.on_store(self) if src.is_a?(Hookable) && src.respond_to?(:on_store) #convention hook for []=

        value
      end

      def unbind
        params.each { |param| param.unbind }

        return unless @source
        src = @source.object
        return @source, @type, @qual = nil unless src

        src = source
        src.remove_hook(:on_store, self) if src.is_a?(Hookable) && src.respond_to?(:on_store)
        nil
      end

      def call(parms)
        return unless parms[:args] == params_values
        owner.send("#{@type}_changed")
      end

      def owner=(o)
        @owner, left.owner = o, o
        params.each { |param| param.owner = o }
      end

      def rightmost
        self
      end

      def unparse
        "#{left.unparse}[#{params.map(&:unparse).join(',')}]"
      end

      def value
        source[*params_values]
      end

      def value=(v)
        source[*params_values] = v
      end

      protected
      def source
        raise UnboundError unless @source
        src = @source.object
        raise UnboundError unless src
        src
      end

      def params_values
        params.map { |param| param.value }
      end
    end
  end
end