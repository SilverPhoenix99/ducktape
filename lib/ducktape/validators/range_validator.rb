module Ducktape
  class RangeValidator
    def initialize(range)
      @range = range
    end

    def validate(obj)
      @range.include?(obj)
    end

    def self.matches?(obj)
      obj.is_a?(Range)
    end
  end
end