module Ducktape
  module Bindable
    class BindingSource

      FORWARD_MASK = 1
      REVERSE_MASK = 2

      def initialize(source, attribute, direction: :both, &converter)
        @source = source.instance_variable_get(:"@#{attribute}")
        @converter = converter || ->(value, _direction) { value }

        @direction = case direction
          when :forward then FORWARD_MASK
          when :reverse then REVERSE_MASK
          when :both    then FORWARD_MASK | REVERSE_MASK
          else raise ArgumentError.new(direction: direction)
        end
      end

      def bind(target)
        @source.on_changed(self) { |**| target.value = self.source_value } if forward?
        target.on_changed(self) { |**| @source.value = @converter.(target.value, :reverse) } if reverse?
      end

      def source_value
        @converter.(@source.value, :forward)
      end

      def unbind(target)
        @source.remove_hook :on_changed, self
        target.remove_hook :on_changed, self
      end

      def direction
        case @direction
          when FORWARD_MASK then :forward
          when REVERSE_MASK then :reverse
          else :both
        end
      end

      def forward?
        @direction & FORWARD_MASK != 0
      end

      def reverse?
        @direction & REVERSE_MASK != 0
      end
    end
  end
end
