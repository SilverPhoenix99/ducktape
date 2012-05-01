module Ducktape
  module Hookable

    module ClassMethods
      def def_hook(*events)
        events.each { |e| define_method e, ->(&block){ add_hook(e, &block) } }
      end
    end

    def self.included(base)
      base.extend(ClassMethods)
    end

    def self.extended(_)
      raise 'Cannot extend, only include.'
    end

    def add_hook(event, &block)
      return unless block
      self.hooks[event.to_s].unshift block
      nil
    end

    def remove_hook(event, block)
      self.hooks[event.to_s].delete(block)
    end

    def clear_hooks(event = nil)
      if event
        self.hooks.delete(event.to_s)
      else
        self.hooks.clear
      end
      nil
    end

    protected
    def hooks
      @hooks ||= Hash.new { |h,k| h[k.to_s] = [] }
    end

    def call_hooks(event, caller, *args)
      return unless self.hooks.has_key? event.to_s
      self.hooks[event.to_s].each { |hook| hook.call(event, caller, *args) }
      nil
    end

    def call_handlers(event, caller, *args)
      return unless self.hooks.has_key? event.to_s
      self.hooks[event.to_s].each do |hook|
        handled = hook.call(event, caller, *args)
        return handled if handled
      end
      nil
    end
  end
end