module Ducktape
  class Link

    class ModeError < StandardError; end

    include Ref #WeakReference

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
      with_cleanup { @expression.bind(@source.object, :value) }
      nil
    end

    def unbind
      with_cleanup { @expression.unbind }
      nil
    end

    def update_source
      assert_mode :set, :source, :reverse
      with_cleanup { @expression.value = target_value }
    end

    def update_target
      assert_mode :set, :target, :forward
      with_cleanup { @target.object.set_value source_value }
    end

    def source_value
      assert_mode :get, :source, :forward
      with_cleanup { @converter.convert(@expression.value) }
    end

    def target_value
      assert_mode :get, :target, :reverse
      with_cleanup { @converter.revert(@target.object.value) }
    end

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

      def with_cleanup
        return yield unless broken?
        unbind if @expression
        @target.object.remove_source if @target && @target.object
        @source, @target, @expression = nil
      end
  end
end