module Ducktape
  class Converter
    def initialize(convert = ->(v){v}, revert = nil)
      @cnv, @rev = convert, revert || convert
    end

    def convert(value)
      @cnv.(value)
    end

    def revert(value)
      @rev.(value)
    end

    def self.convert(value)
      value
    end

    def self.revert(value)
      value
    end
  end
end