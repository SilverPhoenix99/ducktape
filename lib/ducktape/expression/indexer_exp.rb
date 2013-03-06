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
        @args = params.map { |param| param.value }

        src.on_store(self) if src.is_a?(Hookable) && src.respond_to?(:on_store) #convention hook for []=

        value
      end

      def unbind
        return unless @source
        src = @source.object
        return @source, @type, @qual = nil unless src

        src = source
        src.remove_hook(:on_store, self) if src.is_a?(Hookable) && src.respond_to?(:on_store)
        nil
      end

      def call(parms)
        return unless parms[:args] == @args
        owner.send("#{@type}_changed")
      end

      def rightmost
        self
      end

      def unparse
        "#{left.unparse}[#{params.map(&:unparse).join(',')}]"
      end

      def value
        #TODO validate source
        @source.object[*@args]
      end

      def value=(v)
        #TODO validate source
        @source.object[*@args] = v
      end

      protected
      def source
        raise UnboundError unless @source
        src = @source.object
        raise UnboundError unless src
        src
      end
    end
  end
end