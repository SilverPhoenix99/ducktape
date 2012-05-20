module Ducktape
  class BindableAttributeMetadata

    VALID_OPTIONS = [:access, :default, :validate, :coerce].freeze

    attr_reader :name

    def initialize(name, options = {})

      options.keys.reject { |k| VALID_OPTIONS.member?(k) }.
        each { |k| puts "WARNING: invalid option #{k.inspect} for #{name.inspect} attribute. Will be ignored." }

      if name.is_a? BindableAttributeMetadata
        @name = name.name
        @default = options[:default] || name.instance_variable_get(:@default)
        @validation = options[:validate] || name.instance_variable_get(:@validation)
        @coercion = options[:coerce] || name.instance_variable_get(:@coercion)
      else
        @name = name
        @default = options[:default]
        @validation = options[:validate]
        @coercion = options[:coerce]
      end

      @validation = [*@validation] unless @validation.nil?
    end

    def default=(value)
      @default = value
    end

    def default
      @default.is_a?(Proc) ? @default.call : @default
    end

    def validation(*options, &block)
      options << block
      @validation = options
    end

    def validate(value)
      return true unless @validation
      @validation.each do |v|
        return true if ( v.is_a?(Class)  && value.is_a?(v) ) ||
                       ( v.is_a?(Proc)   && v.(value)      ) ||
                       ( v.is_a?(Regexp) && value =~ v     ) ||
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