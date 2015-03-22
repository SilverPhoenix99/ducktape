module Ducktape
  class RegexpValidator
    def initialize(regexp)
      @regexp = regexp
    end

    def validate(obj)
      obj =~ @regexp
    end

    def self.matches?(obj)
      obj.is_a?(Regexp)
    end
  end
end