module Ducktape
  module HookableCollection
    extend Hookable::ClassMethods

    module ClassMethods
      def compile_hooks(names_ary, names_hash = {})
        #Reversed merge because names_hash has priority.
        names_hash = Hash[names_ary.map { |v| [v, v] }].merge!(names_hash)

        names_hash.each do |name, aka|
          aka = "on_#{aka}"
          def_hook(aka) unless method_defined?(aka)
          defined_hooks[name.to_s] = aka
        end

        nil
      end

      def defined_hooks
        @defined_hooks ||= {}
      end
    end

    def self.included(base)
      base.send(:include, Hookable)
      base.extend(ClassMethods)
    end

    def self.extended(_)
      raise 'Cannot extend, only include.'
    end

    def_hook 'on_changed'

    def content() @content.dup end
    def to_s() "#{self.class}#{@content.to_s}" end
    def inspect() "#{self.class}#{@content.inspect}" end
    def hash() @content.hash end
    def dup() self.class.new(@content) end

    def eq?(other)
      equal?(other) || self == other
    end

    def method_missing(name, *args, &block)
      result = @content.public_send(name, *args, &block)
      result = self if result.equal?(@content)

      aka = self.class.defined_hooks[name.to_s]
      if aka
        call_hooks(aka, self, args, result)
        call_hooks('on_changed', self, name, args, result)
      end

      result
    end
  end
end