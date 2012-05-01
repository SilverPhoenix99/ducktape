module Ducktape
  class HookableArray
    include Hookable

    def self.[](*args)
      new(*args)
    end

    def self.try_convert(obj)
      return obj if obj.is_a? self
      obj = Array.try_convert(obj)
      return nil if obj.nil?
      new(obj)
    end

    def initialize(*args, &block)
      @array = if args.length == 1 && (args[0].is_a?(Array) || args[0].is_a?(HookableArray))
        args[0]
      else
        Array.new(*args, &block)
      end
    end

    def method_missing(name, *args, &block)
      @array.public_send(name, *args, &block)
    end

    def to_s() @array.to_s end
    def inspect() @array.inspect end
    def to_ary() self end

    def_hook 'on_changed'

    compile_hook = ->(name, aka = nil) do
      aka ||= name
      aka = "on_#{aka}"

      def_hook(aka) unless method_defined?(aka)

      define_method(name) do |*args, &block|
        result = @array.public_send(__method__, *args, &block)
        call_hooks(aka, self, args, result)
        call_hooks('on_changed', self, name, args, result)
        result
      end
    end

    %w'clear collect! compact! concat delete delete_at delete_if fill flatten! insert keep_if
       map! pop push reject! replace reverse! rotate! select! shift shuffle! slice! sort!
       sort_by! uniq! unshift'.each { |m| compile_hook.(m) }

    { '[]=' => 'assoc', '<<' => 'append' }.each { |k, v| compile_hook.(k, v) }
  end
end