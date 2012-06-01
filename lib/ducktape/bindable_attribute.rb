autoload :Set, 'set'

module Ducktape

  class InvalidAttributeValueError < StandardError
    def initialize(name, value)
      super("value #{value.inspect} is invalid for attribute #{name.to_s.inspect}")
    end
  end

  class BindableAttribute

    include Hookable

    attr_reader :owner    # Bindable
    attr_reader :name     # String
    attr_reader :source   # BindingSource
    attr_reader :value    # Object

    #attr_reader :targets # Hash{ BindableAttribute => BindingSource }

    #def_hook :on_changed

    def initialize(owner, name)
      @owner, @name, @source, @targets = owner, name.to_s, nil, {}
      reset_value
    end

    def metadata
      @owner.class.metadata(@name)
    end

    def has_source?
      !@source.nil?
    end

    def value=(value)
      set_value(value)
    end

    #If values are equal, it means that both attributes share the same value,
    #if they are different, the values are independent.
    #As such, self's value is reset if mode is both, or if mode is forward and values are equal;
    #the source's value is reset of mode is reverse and values are equal.
    def remove_source
      return unless has_source?
      bs, v = detach_source
      reset_value if bs.mode == :both || (bs.mode == :forward && v == @value)
      bs
    end

    def reset_value
      set_value(metadata.default)
    end

    private #----------------------------------------------------------------

    attr_reader :targets

    def set_value(value, exclusions = Set.new)
      return if exclusions.include? self
      exclusions << self

      if value.is_a? BindingSource
        attach_source(value) #attach new binding source
        exclusions << @source.source #update value
        value = @source.source.value #new value is the new source value
      end

      #set effective value
      if @value != value
        m = metadata
        value = m.coerce(owner, value)
        raise InvalidAttributeValueError.new(@name, value) unless m.validate(value)
        old_value = @value
        @value = value

        old_value.remove_hook('on_changed', method('hookable_value_changed')) if old_value.respond_to?('on_changed')
        @value.on_changed(method('hookable_value_changed')) if @value.respond_to?('on_changed')

        call_hooks('on_changed', owner, attribute: name, value: @value, old_value: old_value)
      end

      propagate_value(exclusions)
      @value
    end

    def detach_source
      bs = @source
      v = bs.source.value
      @source = nil
      bs.source.send(:targets).delete(self)
      bs.source.reset_value if bs.mode == :reverse && v == @value
      [bs, v]
    end

    # source: BindingSource
    def attach_source(source)
      detach_source
      @source = source
      source.source.send(:targets)[self] = source
      nil
    end

    def targets_to_propagate
      targets = []
      targets << @source.source if @source && BindingSource::PROPAGATE_TO_SOURCE.member?(@source.mode)
      targets.concat(@targets.values.select { |b| BindingSource::PROPAGATE_TO_TARGETS.member?(b.mode) })
    end

    def propagate_value(exclusions)
      targets_to_propagate.each { |target| target.set_value(value, exclusions) }
      nil
    end

    def hookable_value_changed(*_)
      call_hooks('on_changed', owner, attribute: name, value: @value)
      nil
    end
  end
end