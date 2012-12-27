module Ducktape
  class BindableAttributeMetadata

    VALID_OPTIONS = [:access, :coerce, :default, :getter, :setter, :validate].freeze

    attr_reader :name, :access, :getter, :setter

    def initialize(name, options = {})

      options.keys.reject { |k| VALID_OPTIONS.member?(k) }.
        each { |k| puts "WARNING: invalid option #{k.inspect} for #{name.inspect} attribute. Will be ignored." }

      if name.is_a? BindableAttributeMetadata
        @name       = name.name
        @default    = options.has_key?(:default) ? options[:default] : name.instance_variable_get(:@default)
        @validation = options.has_key?(:validate) ? options[:validate] : name.instance_variable_get(:@validation)
        @coercion   = options.has_key?(:coerce) ? options[:coerce] : name.instance_variable_get(:@coercion)
        @access     = options.has_key?(:access) ? options[:access] : name.access
        @getter     = options.has_key?(:getter) ? options[:getter] : name.getter
        @setter     = options.has_key?(:setter) ? options[:setter] : name.setter
      else
        @name       = name
        @default    = options[:default]
        @validation = options[:validate]
        @coercion   = options[:coerce]
        @access     = options[:access]
        @getter     = options[:getter]
        @setter     = options[:setter]
      end

      @validation = [*@validation] unless @validation.nil?
    end

    def default=(value)
      @default = value
    end

    def default
      @default.respond_to?('call') ? @default.call : @default
    end

    def validation(*options, &block)
      options << block
      @validation = options
    end

    def validate(value)
      return true unless @validation
      @validation.each do |v|
        return true if ( v.is_a?(Class)        && value.is_a?(v) ) ||
                       ( v.respond_to?('call') && v.(value)      ) ||
                       ( v.is_a?(Regexp)       && value =~ v     ) ||
                         value == v
      end
      false
    end

    def coercion(&block)
      @coercion = block
    end

    def coerce(owner, value)
      @coercion ? @coercion.call(owner, value) : value
    end
  end
end