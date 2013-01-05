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
        options[:access] ||= :both
        m = BindableAttributeMetadata.new(metadata(name) || name, options)
        bindings_metadata[name] = m
        raise InconsistentAccessorError.new(true, name)  if options[:access] == :writeonly && options[:getter]
        raise InconsistentAccessorError.new(false, name) if options[:access] == :readonly && options[:setter]

        define_method name, options[:getter] || ->() { get_value(name) } unless options[:access] == :writeonly

        unless options[:access] == :readonly
          define_method "#{name}=", options[:setter] || ->(value) { set_value(name, value) }
        end
        nil
      end

      #TODO improve metadata search
      def metadata(name)
        name = name.to_s
        m = bindings_metadata[name]
        return m if m
        a = ancestors.find { |a| a != self && a.respond_to?(:metadata) }
        return nil unless a && (m = a.metadata(name))
        m = m.dup
        bindings_metadata[name] = m
      end

      protected
      def bindings_metadata
        @bindings_metadata ||= {}
      end
    end

    def self.included(base)
      base.extend(ClassMethods)
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

    def unbind_source(attr_name)
      get_bindable_attr(attr_name).remove_source
      nil
    end

    def clear_bindings()
      bindable_attrs.each { |_, attr| attr.remove_source }
      nil
    end

    def on_changed(attr_name, hook = nil, &block)
      return nil unless block || hook
      get_bindable_attr(attr_name).on_changed(hook, &block)
      block
    end

    def unhook_on_changed(attr_name, block)
      return nil unless block
      get_bindable_attr(attr_name).remove_hook(:on_changed, block)
      block
    end

    protected #--------------------------------------------------------------

    def get_value(attr_name)
      get_bindable_attr(attr_name).value
    end

    def set_value(attr_name, value)
      get_bindable_attr(attr_name).value = value
    end

    private #----------------------------------------------------------------

    def bindable_attrs
      @bindable_attrs ||= {}
    end

    def get_bindable_attr(name)
      raise AttributeNotDefinedError.new(self.class, name.to_s) unless self.class.metadata(name)
      bindable_attrs[name.to_s] ||= BindableAttribute.new(self, name)
    end
  end
end