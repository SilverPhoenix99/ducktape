module Ducktape

  class InvalidAttributeValueError < StandardError
    def initialize(name, value)
      super("value #{value.inspect} is invalid for attribute '#{name}'")
    end
  end

  class BindableAttribute

    include Hookable

    attr_reader :owner,    # Bindable
                :name,     # Symbol
                :source,   # BindableSource
                #:targets, # { BindableAttribute => BindableSource }
                :value     # Object

    def_hook :on_changed

    def initialize(owner, name)
      @owner, @name, @targets, @source = owner, name, {}, nil
      reset_value(false)
    end

    def metadata
      @owner.class.metadata(@name)
    end

    def value=(value)
      set_value(value)
    end

    def remove_source(propagate = true)
      detach(@source, self, propagate)
    end

    def reset_value(propagate = true)
      meta = metadata
      value = @source ? @source.source.value : meta.default

      if propagate
        self.value = value
      else
        @value = value
      end

      nil
    end

    protected #--------------------------------------------------------------

    def set_value(value, exclusions = Set.new)
      return if exclusions.member? self
      exclusions << self

      if value.is_a? BindableSource
        BindableAttribute.attach(value, self, false)

        #update value
        exclusions << @source.source

        #new value is the new source value
        value = @source.source.value
      end

      #set effective value
      if @value != value
        m = metadata
        value = m.coerce(owner, value)
        raise InvalidAttributeValueError.new(@name, value) unless m.validate(value)
        old_value = @value
        @value = value
        call_hooks('on_changed', owner, name, @value, old_value)
      end

      #propagate value
      @source.source.set_value(value, exclusions) if propagate_to_source
      targets_to_propagate.each { |target, _| target.set_value(value, exclusions) }
    end

    private #----------------------------------------------------------------

    def propagate_to_source
      return false unless @source
      BindableSource::PROPAGATE_TO_SOURCE.member? @source.mode
    end

    def targets_to_propagate
      @targets.select { |_, b| BindableSource::PROPAGATE_TO_TARGETS.member? b.mode }
    end

    # source: BindableSource
    def self.attach(source, target, propagate)
      target.instance_eval {
        detach(@source.source, self, false) if @source
        @source = source
        reset_value(propagate)
      }

      source.source.instance_eval { @targets[target] = source }
    end

    # source: BindableAttribute
    def self.detach(source, target, propagate)
      return unless target.source and target.source.source == source

      source.instance_eval { @targets.delete(target) }
      target.instance_eval { @source = nil; reset_value(propagate) }

      nil
    end
  end
end