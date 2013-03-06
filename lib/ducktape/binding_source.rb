module Ducktape
  class BindingSource
    PROPAGATE_TO_TARGET = [:forward, :both].freeze
    PROPAGATE_TO_SOURCE = [:reverse, :both].freeze

    attr_reader :source,   # Bindable | Object
                :path,     # String | Symbol
                :mode,     # :forward, :reverse, :both
                :converter # Converter

    def initialize(source, path, mode = :both, converter = Converter)
      @source, @path, @mode = source, path, mode
      @converter = make_converter(converter)
    end

    def forward?
      PROPAGATE_TO_TARGET.include?(@mode)
    end

    def reverse?
      PROPAGATE_TO_SOURCE.include?(@mode)
    end

    private
    def make_converter(c)
      case c
        when nil then Converter
        when Class then (c.respond_to?(:convert) && c.respond_to?(:revert)) ? c : c.new
        when Proc, Method, Array then Converter.new(*c)
        else c
      end
    end
  end
end