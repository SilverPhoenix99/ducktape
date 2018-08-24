require_relative '../exception'
require_relative '../hookable'
require_relative 'binding_source'

module Ducktape

  class AttributeError < StandardError; end
  class InvalidTypeError < AttributeError; end
  class UnknownOptionError < AttributeError; end
  class AlreadyNamedError < AttributeError; end
  class UnnamedError < AttributeError; end
  class AccessorError < AttributeError; end
  class EmptyValidatorsError < AttributeError; end
  class InvalidValueError < AttributeError; end

  module Bindable
    class Attribute

      include Hookable

      ANY_TYPE = ->(_value) { true }

      VALID_OPTIONS = %i{name default getter setter validate}

      @default = ->() { nil }
      @getter = @setter = ->(value) { value }
      @validators = [ANY_TYPE].freeze

      module ClassMethods
        def name
          @name || superclass.name
        end

        def default
          @default || superclass.default
        end

        def getter
          @getter || superclass.getter
        end

        def setter
          @setter || superclass.setter
        end

        def validators
          @validators || superclass.validators
        end
      end

      class << self
        attr_reader :name, :default, :getter, :setter, :validators

        def build_subclass(superclass = Attribute, **options)
          raise InvalidTypeError.new('not a subtype of Attribute', type: superclass) unless superclass <= Attribute

          invalid_option = options.each_key.find { |opt| !VALID_OPTIONS.include?(opt) }

          if invalid_option
            raise UnknownOptionError.new(attribute: self.name || options[:name], unknown_option: invalid_option)
          end

          Class.new(superclass) do
            extend ClassMethods

            if options.has_key?(:name)
              @name = options[:name]
              if superclass.name && @name != superclass.name
                raise AlreadyNamedError.new(attribute: superclass.name, new_name: @name)
              end
            end

            raise UnnamedError unless self.name

            if options.has_key?(:default)
              @default = options[:default]
              unless @default.is_a?(Proc)
                default_value = @default
                @default = gen_dft_proc(default_value)
              end
            end

            if options.has_key?(:getter)
              @getter = options[:getter]
              unless @getter.is_a?(Proc)
                raise AccessorError.new('getter is not callable', attribute: self.name, getter: @getter)
              end
            end

            if options.has_key?(:setter)
              @setter = options[:setter]
              unless @setter.is_a?(Proc)
                raise AccessorError.new('setter is not callable', attribute: self.name, setter: @setter)
              end
            end

            if options.has_key?(:validate)
              @validators = options[:validate]
              @validators = [nil] if @validators.nil?
              @validators = [*@validators].freeze
            end

            raise EmptyValidatorsError.new('validate cannot be empty', attribute: self.name) if self.validators.empty?
          end
        end

        private def gen_dft_proc(default_value)
          -> { default_value }
        end
      end

      def initialize(owner, **options)
        @owner = owner
        value = options.has_key?(:value) ? options.delete(:value) : self.class.default.()

        unless options.empty?
          raise UnknownOptionError.new(attribute: self.class.name, unknown_option: options.first.first)
        end

        self.value = value
      end

      def value
        @owner.instance_exec(@value, &self.class.getter)
      end

      def value=(value)
        if value.is_a?(BindingSource)
          self.source = value
          self.value = @source.source_value if @source.forward?
          return value
        end

        new_value = @owner.instance_exec(value, &self.class.setter)
        validate new_value

        return value if new_value.equal?(@value) || new_value == @value

        old_value = @value
        @value = new_value

        call_hook :on_changed, sender: @owner, attribute: self.class.name, old_value: old_value, new_value: new_value

        value
      end

      private def validate(value)
        return if self.class.validators.any? { |validator| validator === value }
        raise InvalidValueError.new(attribute: self.class.name, invalid_value: value, validators: self.class.validators)
      end

      def reset_value
        self.value = self.class.default.()
      end

      def remove_source
        old_source = @source
        self.source = nil
        old_source
      end

      protected def source=(new_source)
        @source&.unbind self
        @source = new_source
        @source&.bind self

        new_source
      end
    end
  end
end
