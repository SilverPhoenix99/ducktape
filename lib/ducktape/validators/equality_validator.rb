module Ducktape
  class EqualityValidator
    def initialize(obj)
      @obj = obj
    end

    def validate(obj)
      obj == @obj
    end

    def self.matches?(_)
      true
    end
  end
end