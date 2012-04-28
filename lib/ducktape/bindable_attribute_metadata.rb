module Ducktape
  class BindableAttributeMetadata

  		attr_reader :name

  		def initialize(name, options = {})
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
  			@validation.each do |validation|
  				return true if (validation.is_a?(Class) and value.is_a?(validation)) or
  							   (validation.is_a?(Proc) and validation.call(value)) or
  								value == validation
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