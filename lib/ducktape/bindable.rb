module Ducktape

  class AttributeNotDefinedError < StandardError
    def initialize(klass, name)
      super("attribute #{name.to_s.inspect} not defined for class #{klass}")
    end
  end

  module Bindable
    module ClassMethods
      def bindable(name, options = {})
        name = name.to_s
        m = BindableAttributeMetadata.new(metadata(name) || name, options)
        bindings_metadata[name] = m
        define_method name, ->() { get_value(name) } unless options[:access] == :writeonly
        define_method "#{name}=", ->(value) { set_value(name, value) } unless options[:access] == :readonly
        nil
      end

      #TODO improve metadata search
      def metadata(name)
        name = name.to_s
        m = bindings_metadata[name]
        return m if m
        return nil unless superclass.respond_to?(:metadata) && (m = superclass.metadata(name))
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
    end

    def self.extended(_)
      raise 'Cannot extend, only include.'
    end

    def unbind_source(name)
      get_bindable_attr(name.to_s).remove_source(true)
      nil
    end

    def clear_bindings()
      bindable_attrs.each { |_,attr| attr.remove_source() }
      nil
    end

    def on_changed(attr_name, &block)
      return nil unless block
      get_bindable_attr(attr_name.to_s).on_changed(&block)
      block
    end

    def unhook_on_changed(attr_name, block)
      return nil unless block
      get_bindable_attr(attr_name.to_s).send(:remove_hook, :on_changed, block)
      block
    end

    protected
    def get_value(attr_name)
      get_bindable_attr(attr_name.to_s).value
    end

    def set_value(attr_name, value)
      get_bindable_attr(attr_name.to_s).value = value
    end

    private
    def bindable_attrs
      @bindable_attrs ||= {}
    end

    def get_bindable_attr(name)
      raise AttributeNotDefinedError.new(self.class, name.to_s) unless self.class.metadata(name)
      bindable_attrs[name.to_s] ||= BindableAttribute.new(self, name)
    end
  end
end