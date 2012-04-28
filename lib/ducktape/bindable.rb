module Ducktape
  module Bindable
    module ClassMethods
      def inherited(child)
        super
        child.instance_eval { @bindings_metadata = {} }
      end

      def bindable(name, options = {})
        m = BindableAttributeMetadata.new(metadata(name) || name, options)
        @bindings_metadata[name.to_s] = m
        define_method name, ->{get_bindable_attr(name).value} if !options.has_key?(:readable) or options[:readable]
        define_method "#{name}=", ->(value){get_bindable_attr(name).value = value} if !options.has_key?(:writable) or options[:writable]
        nil
      end

      #TODO improve metadata search
      def metadata(name)
        m = @bindings_metadata[name.to_s]
        return m if m
        return nil unless superclass.respond_to?(:metadata) && (m = superclass.metadata(name))
        m = m.dup
        @bindings_metadata[name.to_s] = m
      end
    end

    def self.included(base)
      base.extend(ClassMethods)
      base.instance_eval { @bindings_metadata = {} }
    end

    def self.extended(_)
      raise 'Cannot extend, only include.'
    end

    def unbind_source(name)
      get_bindable_attr(name).remove_source(true)
      nil
    end

    def clear_bindings()
      bindable_attrs.each { |_,attr| attr.remove_source() }
      nil
    end

    def on_changed(attr_name, &block)
      return nil unless block
      get_bindable_attr(attr_name).send(:on_changed, &block)
      block
    end

    def unhook_on_changed(attr_name, block)
      return nil unless block
      get_bindable_attr(attr_name).send(:remove_hook, :on_changed, block)
      block
    end

    private
    def bindable_attrs
      @bindable_attrs ||= {}
    end

    def get_bindable_attr(name)
      bindable_attrs[name] ||= BindableAttribute.new(self, name)
    end
  end
end