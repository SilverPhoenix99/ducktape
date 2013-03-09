module Ducktape
  class Link
    include Ref #WeakReference

    class ModeError < StandardError; end

    class << self
      def cleanup(*method_names)
        method_names.each do |method_name|
          m = instance_method(method_name)
          define_method(method_name, ->(*args, &block) do
            return m.bind(self).(*args, &block) unless broken?
            unbind if @expression
            @target.object.remove_source if @target && @target.object
            @source, @target, @expression = nil
          end)
        end
      end
    end

    attr_accessor :source,     # WeakRef of Object
                  :expression, # Expression (e.g.: 'a::X.b[c,d]')
                  :target,     # WeakRef of BindingAttribute
                  :converter,  # Method
                  :mode        # :forward, :reverse, :both

    attr_reader :binding_source

    def initialize(binding_source, target)
      @binding_source = binding_source
      @source         = WeakReference.new(binding_source.source)
      @expression     = Expression::BindingParser.parse(binding_source.path)
      @target         = WeakReference.new(target)
      @converter      = binding_source.converter
      @mode           = binding_source.mode

      @expression.owner = self
    end
    
    def broken?
      !(@source && @target && @source.object && @target.object)
    end

    def forward?
      BindingSource::PROPAGATE_TO_TARGET.include?(@mode)
    end

    def reverse?
      BindingSource::PROPAGATE_TO_SOURCE.include?(@mode)
    end

    def bind
      @expression.bind(@source.object, :value)
      nil
    end

    def unbind
      @expression.unbind
      nil
    end

    def update_source
      assert_mode :set, :source, :reverse
      @expression.value = target_value
    end

    def update_target
      assert_mode :set, :target, :forward
      @target.object.value = source_value
    end

    def source_value
      assert_mode :get, :source, :forward
      @converter.convert(@expression.value)
    end

    def target_value
      assert_mode :get, :target, :reverse
      @converter.revert(@target.object.value)
    end

    cleanup :bind, :unbind, :update_source, :update_target, :source_value, :target_value

    private
    def assert_mode(accessor, type, mode)
      raise ModeError, "cannot #{accessor} #{type} value on a non #{mode} link" unless public_send("#{mode}?")
    end

    def path_changed
      bind
      forward? ? update_target : update_source
      nil
    end

    def value_changed
      return unless forward?
      update_target
      nil
    end
  end
end