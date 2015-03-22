module Ducktape
  class ProcValidator
    def initialize(proc)
      @proc = proc
    end

    def validate(obj)
      @proc.(obj)
    end

    def self.matches?(obj)
      obj.respond_to?(:call)
    end
  end
end