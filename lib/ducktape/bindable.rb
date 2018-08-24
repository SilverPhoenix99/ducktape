require_relative '../ducktape'
require_relative 'bindable/attribute'

module Ducktape
  class InvalidAttributeNameError < StandardError; end

  module Bindable

    module ClassMethods
      def bindable(name, **options)
        attr_superclass = ancestors.lazy
            .select { |m| m != self && m < Bindable }
            .map { |m| m.instance_variable_get(:@bindable_attr_classes)&.[](name) }
            .find(&:itself) || Attribute

        (@bindable_attr_classes ||= {})[name] = Attribute.build_subclass(attr_superclass, name: name, **options)

        module_eval <<-EOS
          def #{name}() @#{name}.value end
          def #{name}=(value) @#{name}.value = value end
        EOS

        nil
      end
    end

    module Initializer
      def initialize(*args, **options, &block)
        unless caller_locations(1, 1).first.label == __method__.to_s

          attr_classes = self.class.ancestors.lazy
            .reverse_each
            .map { |m| m.instance_variable_get(:@bindable_attr_classes) }
            .select(&:itself)
            .reduce({}, &:merge!)

          attr_classes.each do |name, attr_class|
            attr_name = :"@#{name}"
            next if instance_variable_defined?(attr_name)
            attr_options = options.has_key?(name) ? { value: options.delete(name) } : {}
            instance_variable_set attr_name, attr_class.new(self, **attr_options)
          end
        end

        args << options unless options.empty?

        # noinspection RubySuperCallWithoutSuperclassInspection
        super *args, &block
      end
    end

    module Inheritable
      def inherited(c)
        unless caller_locations(1, 1).first.label == __method__.to_s
          c.prepend Initializer
          c.singleton_class.prepend Inheritable
        end
        # noinspection RubySuperCallWithoutSuperclassInspection
        super if defined?(super)
      end
    end

    def self.included(mod)
      mod.extend ClassMethods
      mod.prepend Initializer
      mod.singleton_class.prepend Inheritable
    end

    def reset_attr(name)
      get_attr(name).reset_value
    end

    def unbind_attr(name)
      get_attr(name).remove_source
    end

    private def get_attr(name)
      attr = instance_variable_get(:"@#{name}")
      raise InvalidAttributeNameError.new(name: name) unless attr.is_a?(Attribute)
      attr
    end
  end
end
