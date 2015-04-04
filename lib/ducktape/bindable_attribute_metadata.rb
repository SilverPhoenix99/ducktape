module Ducktape
  class BindableAttributeMetadata

    @validators = [ ClassValidator, ProcValidator, RegexpValidator, RangeValidator, EqualityValidator ]

    VALID_OPTIONS = [:access, :coerce, :default, :getter, :setter, :validate].freeze

    attr_reader :name, :access, :getter, :setter

    def initialize(name, options = {})

      options.keys.reject { |k| VALID_OPTIONS.member?(k) }.
        each { |k| $stderr.puts "WARNING: invalid option #{k.inspect} for #{name.inspect} attribute. Will be ignored." }

      @name = if name.is_a?(BindableAttributeMetadata)
                options = name.send(:as_options).merge!(options)
                name.name
              else
                name
              end

      @default    = options[:default]
      @validation = validation(*options[:validate])
      @coercion   = options[:coerce]
      @access     = options[:access] || :both
      @getter     = options[:getter]
      @setter     = options[:setter]
    end

    def default=(value)
      @default = value
    end

    def default
      @default.respond_to?(:call) ? @default.call : @default
    end

    def getter_proc
      self.class.getter_proc(@getter, @name)
    end

    def setter_proc
      self.class.setter_proc(@setter, @name)
    end

    def validation(*validators, &block)
      validators << block if block
      class_validators = Set.new(self.class.instance_variable_get(:@validators))
      @validation = validators.map do |validator|
        class_validators.include?(validator.class) ? validator : self.class.create_validator(validator)
      end
    end

    def valid?(value)
      @validation.empty? || @validation.any? { |validator| validator.validate(value) }
    end

    def validate(value)
      raise InvalidAttributeValueError.new(@name, value) unless valid?(value)
    end

    def coercion(proc_obj = nil, &block)
      raise ArgumentError, 'Expected only a parameter or a block, but both were passed.' if proc_obj && block
      @coercion = block || proc_obj
    end

    def coerce(owner, value)
      @coercion ? @coercion.(owner, value) : value
    end

    def self.register_validator(validator_class)
      @validators.unshift validator_class
    end

    private

      def as_options
        {
          default:  @default,
          validate: @validation,
          coerce:   @coercion,
          access:   @access,
          getter:   @getter,
          setter:   @setter
        }
      end

      def self.create_validator(validator)
        validator_class = @validators.find { |validator_class| validator_class.matches?(validator) }
        validator_class.new(validator)
      end

      def self.getter_proc(getter, name)
        case getter
          when Proc           then getter
          when Symbol, String then ->() { send(getter) }
          when nil            then ->() { get_value(name) }
          else raise ArgumentError, 'requires a Proc, a Symbol or nil'
        end
      end

      def self.setter_proc(setter, name)
        case setter
          when Proc           then setter
          when Symbol, String then ->(value) { send(setter, value) }
          when nil            then ->(value) { set_value(name, value) }
          else raise ArgumentError, 'requires a Proc, a Symbol or nil'
        end
      end
  end
end
