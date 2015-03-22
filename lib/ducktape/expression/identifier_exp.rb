module Ducktape
  module Expression
    class IdentifierExp
      include Ref, LiteralExp

      def bind(src, type, qual = nil, _ = src)
        unbind
        @source, @type, @qual = WeakReference.new(src), type, qual

        case
          when src.is_a?(Bindable) && src.bindable_attr?(literal) then src.on_changed(literal, self)
          when src.is_a?(Hookable) then src.on_changed(self)
        end

        value
      end

      def unbind
        return unless @source
        src = @source.object
        return @source, @type, @qual = nil unless src

        case
          when src.is_a?(Bindable) && src.bindable_attr?(literal) then src.unhook_on_changed(literal, self)
          when src.is_a?(Hookable) then src.remove_hook(:on_changed, self)
        end

        @source, @type, @qual = nil
      end

      def call(parms)
        return unless parms[:attribute].to_s == literal.to_s
        owner.send("#{@type}_changed")
        nil
      end

      def rightmost
        self
      end

      def unparse
        literal
      end

      def value
        src = source
        case @qual
          when QualifiedExp then src.const_get(literal)
          when PropertyExp  then src.public_send(literal)
          else is_constant?(src) ? src.const_get(literal) : src.public_send(literal)
        end
      end

      def value=(value)
        src = source
        return unless @type == :value

        case @qual
          when QualifiedExp then src.const_set(literal, value)
          when PropertyExp then property_set(src, value)
          else is_constant?(src) ? src.const_set(literal, value) : property_set(src, value)
        end

        nil
      end

      protected
      def source
        raise UnboundError unless @source
        src = @source.object
        raise UnboundError unless src
        src
      end

      private
      def is_constant?(src)
        literal =~ /^[A-Z]/ && # starts with capital?
        src.respond_to?(:const_defined?) && # source can check for constants (Class, Module)?
        src.const_defined?(literal) # check to see if constant exists
      end

      def property_set(src, value)
        case
          when src.is_a?(Bindable) && src.bindable_attr?(literal)
            src.send(:get_bindable_attr, literal).set_value value
          when src.respond_to?("#{literal}=")
            src.public_send("#{literal}=", value)
          when src.respond_to?(literal) && [-2, -1, 1].include?(src.public_method(literal).arity)
            src.public_send(literal, value)
          else nil # nothing to do
        end
      end
    end
  end
end