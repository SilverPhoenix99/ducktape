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
                #:source        # Link - link between source and target

    def initialize(owner, name)
      @owner, @name, = owner, name.to_s
      @source = nil
      reset_value
    end

    def binding_source
      return unless @source
      @source.binding_source
    end

    def has_source?
      !!@source
    end

    def metadata
      @owner.send(:metadata, @name)
    end

    #After unbinding the source the value can be reset, or kept.
    #The default is to reset the target's (self) value.
    def remove_source(reset = true)
      return unless @source
      src, @source = @source, nil
      src.unbind
      reset_value if reset
      src.binding_source
    end

    def reset_value
      set_value(metadata.default)
    end

    def value=(value)
      set_value(value)
    end

    def to_s
      "#<#{self.class}:0x#{object_id.to_s(16)} @name=#{name}>"
    end

    private #----------------------------------------------------------------

    def set_value(value)
      if value.is_a?(BindingSource) #attach new binding source
        remove_source(false)
        @source = Link.new(value, self).tap { |l| l.bind }

        unless @source.forward?
          @source.update_source
          return @value #value didn't change
        end

        value = @source.source_value
      end

      return @value if value.equal?(@original_value) || value == @original_value # untransformed value is the same?

      original_value = value

      # transform value
      m = metadata
      value = m.coerce(owner, value)
      raise InvalidAttributeValueError.new(@name, value) unless m.validate(value)

      return @value if value.equal?(@value) || value == @value # transformed value is the same?

      #set effective value
      old_value, @value, @original_value = @value, value, original_value
      call_hooks(:on_changed, owner, attribute: name.dup, value: @value, old_value: old_value)

      @source.update_source if @source && @source.reverse?

      @value
    end

    def convert(value)
      value
    end
  end
end