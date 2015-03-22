module Ducktape

  class AttributeNotDefinedError < StandardError
    def initialize(klass, name)
      super("attribute #{name.to_s.inspect} not defined for class #{klass}")
    end
  end

  class InconsistentAccessorError < StandardError
    def initialize(writeonly, name)
      type, accessor = writeonly ? [:Write, :getter] : [:Read, :setter]
      super("#{type} only property with a custom #{accessor}: #{name}")
    end
  end

  module Bindable
    module ClassMethods
      def bindable(name, options = {})
        name = name.to_s
        bindings_metadata[name] = metadata = BindableAttributeMetadata.new(metadata(name) || name, options)
        define_getter metadata
        define_setter metadata
        nil
      end

      def metadata(name)
        name = name.to_s

        meta = ancestors.find do |ancestor|
          bindings = ancestor.instance_variable_get(:@bindings_metadata)
          meta = bindings && bindings[name]
          break meta if meta
        end

        return unless meta
        bindings_metadata[name] = meta
      end

      private

        def bindings_metadata
          @bindings_metadata ||= {}
        end

        def define_getter(metadata)
          if metadata.access == :writeonly
            raise InconsistentAccessorError.new(true, @name) if metadata.getter
            return
          end

          define_method metadata.name, metadata.getter_proc
        end

        def define_setter(metadata)
          if metadata.access == :readonly
            raise InconsistentAccessorError.new(false, @name) if metadata.setter
            return
          end

          define_method "#{metadata.name}=", metadata.setter_proc
        end
    end

    def self.included(base)
      base.extend ClassMethods
      return unless base.is_a?(Module)
      included = base.respond_to?(:included) && base.method(:included)
      base.define_singleton_method(:included, ->(c) do
        included.(c) if included
        c.extend(ClassMethods)
      end)
    end

    def self.extended(_)
      raise 'Cannot extend, only include.'
    end

    def bind(attr_name, *args)
      send "#{attr_name}=", BindingSource.new(*args)
    end

    def bindable_attr?(attr_name)
      !!metadata(attr_name)
    end

    def binding_source(attr_name)
      return unless bindable_attr?(attr_name)
      get_bindable_attr(attr_name).binding_source
    end

    def clear_bindings(reset = true)
      bindable_attrs.each { |_, attr| attr.remove_source(reset) }
      nil
    end

    def on_changed(attr_name, hook = nil, &block)
      return nil unless block || hook
      get_bindable_attr(attr_name).on_changed(hook, &block)
      hook || block
    end

    def unbind_source(attr_name)
      get_bindable_attr(attr_name).remove_source
      nil
    end

    def unhook_on_changed(attr_name, hook)
      return nil unless hook
      get_bindable_attr(attr_name).remove_hook(:on_changed, hook)
      hook
    end

    private #--------------------------------------------------------------

      def get_value(attr_name)
        get_bindable_attr(attr_name).value
      end

      def metadata(name)
        is_a?(Class) ? singleton_class.metadata(name) : self.class.metadata(name)
      end

      def set_value(attr_name, value, &block)
        get_bindable_attr(attr_name).set_value(value, &block)
      end

      def bindable_attrs
        @bindable_attrs ||= {}
      end

      def get_bindable_attr(name)
        raise AttributeNotDefinedError.new(self.class, name.to_s) unless bindable_attr?(name)
        bindable_attrs[name.to_s] ||= BindableAttribute.new(self, name)
      end
  end
end