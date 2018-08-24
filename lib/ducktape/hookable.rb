require_relative '../ducktape'

module Ducktape
  module Hookable
    module ClassMethods
      def def_hook(name)
        define_method(name) do |hook = nil, &hook_block|
          add_hook name, hook, &hook_block
        end
      end

      def def_hooks(*names)
        names.each { |name| def_hook(name) }
      end
    end

    def self.included(mod)
      mod.extend ClassMethods
    end

    protected def hooks
      @hooks ||= Hash.new { |hash, key| hash[key] = {} }
    end

    def add_hook(name, hook = nil, &hook_block)
      case hook
        when String, Symbol
          hook = hook.to_sym
          hooks[name][hook] = hook_block || proc { |*args| send(hook, *args) }

        when nil
          raise ArgumentError, 'no hook provided' unless hook_block
          hooks[name][hook_block] = hook_block

        else
          raise ArgumentError, 'cannot accept both hook argument and block' if hook_block
          hooks[name][hook] = hook_block || hook
      end
    end

    protected def call_hook(name, **event_args)
      return unless @hooks&.has_key?(name)

      @hooks[name].each_value { |hook| hook.(sender: self, **event_args) }
      nil
    end

    def remove_hook(name, key)
      @hooks[name].delete key if @hooks&.has_key?(name)
    end

    def remove_hooks(name)
      @hooks&.delete name
    end

    def clear_hooks
      remove_instance_variable :@hooks
      nil
    end
  end
end
