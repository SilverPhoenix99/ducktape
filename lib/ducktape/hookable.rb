module Ducktape
  module Hookable

    module ClassMethods
      def def_hook(*events)
        events.each { |e| define_method e, ->(method_name = nil, &block){ add_hook(e, method_name, &block) } }
      end
    end

    def self.included(base)
      base.extend(ClassMethods)
    end

    def self.extended(_)
      raise 'Cannot extend, only include.'
    end

    def add_hook(event, hook = nil, &block)
      hook = block if block #block has precedence
      return unless hook
      hook = hook.to_s unless hook.is_a?(Proc)
      self.hooks[event.to_s].unshift(hook)
      hook
    end

    def remove_hook(event, hook)
      hook = hook.to_s unless hook.is_a?(Proc)
      self.hooks[event.to_s].delete(hook)
    end

    def clear_hooks(event = nil)
      if event
        self.hooks.delete(event.to_s)
      else
        self.hooks.clear.dup
      end
    end

    protected
    def hooks
      @hooks ||= Hash.new { |h,k| h[k.to_s] = [] }
    end

    def call_hooks(event, caller, *args)
      return unless self.hooks.has_key? event.to_s
      self.hooks[event.to_s].each do |hook|
        hook = caller.method(hook) unless hook.is_a?(Proc)
        hook.(event, caller, *args)
      end
      nil
    end

    # Similar to `call_hooks`, but stops calling other hooks when a hook returns a value other than nil or false.
    def call_handlers(event, caller, *args)
      return unless self.hooks.has_key? event.to_s
      self.hooks[event.to_s].each do |hook|
        hook = caller.method(hook) unless hook.is_a?(Proc)
        handled = hook.(event, caller, *args)
        return handled if handled
      end
      nil
    end
  end
end