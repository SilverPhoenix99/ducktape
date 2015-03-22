module Ducktape

  class InvalidAttributeValueError < StandardError
    def initialize(name, value)
      super("value #{value.inspect} is invalid for attribute #{name.to_s.inspect}")
    end
  end

  class BindableAttribute

    include Hookable

    attr_reader :owner,         # Bindable
                :name,          # String
                :value          # Object
                #:source_link   # Link - link between source and target

    def initialize(owner, name)
      @owner, @name, @source_link = owner, name.to_s, nil
      reset_value
    end

    def binding_source
      @source_link.binding_source if @source_link
    end

    def has_source?
      !!@source_link
    end

    def metadata
      @owner.send(:metadata, @name)
    end

    #After unbinding the source the value can be reset, or kept.
    #The default is to reset the target's (self) value.
    def remove_source(reset = true)
      return unless @source_link
      src, @source_link = @source_link, nil
      src.unbind
      reset_value if reset
      src.binding_source
    end

    def reset_value
      set_value metadata.default
    end

    def set_value(value)
      if value.is_a?(BindingSource) #attach new binding source
        replace_source value
        return @value unless @source_link.forward? #value didn't change
        value = @source_link.source_value
      end

      original_value, value = value, transform_value(value)

      return @value if value.equal?(@value) || value == @value # transformed value is the same?

      #set effective value
      old_value, @original_value, @value = @value, original_value, value
      yield @value if block_given?
      call_hooks :on_changed, owner, attribute: name.dup, value: @value, old_value: old_value

      @source_link.update_source if @source_link && @source_link.reverse?

      @value
    end

    def to_s
      "#<#{self.class}:0x#{object_id.to_s(16)} @name=#{name}>"
    end

    private

      def replace_source(new_source)
        remove_source false
        @source_link = Link.new(new_source, self)
        @source_link.bind
        @source_link.update_source unless @source_link.forward?
      end

      def transform_value(value)
        metadata = self.metadata
        value = metadata.coerce(owner, value)
        metadata.validate(value)
      end
  end
end