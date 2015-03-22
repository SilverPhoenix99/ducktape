module Ducktape
  class ClassValidator
    def initialize(klass)
      @klass = klass
    end

    def validate(obj)
      obj.is_a?(@klass)
    end

    def self.matches?(obj)
      obj.is_a?(Module)
    end
  end
end