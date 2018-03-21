module Ducktape::Hookable
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
    mod.extend(ClassMethods)
  end

  def initialize
    @hooks = Hash.new { |hash, key| hash[key] = {} }
  end

  def add_hook(name, hook = nil, &hook_block)
    raise ArgumentError, 'cannot accept both hook argument and block' if hook && hook_block
    raise ArgumentError, 'no hook provided' unless hook || hook_block

    hook ||= hook_block
    hook = hook.to_sym if hook.is_a?(String)

    key = hook

    hook = proc { |*args| send(key, *args) } if hook.is_a?(Symbol)

    @hooks[name][key] = hook
  end

  protected def call_hook(name, **event_args)
    return unless @hooks.has_key?(name)

    @hooks[name].each_value { |hook| hook.(sender: self, **event_args) }
    nil
  end

  def remove_hook(name, key)
    @hooks[name].delete(key) if @hooks.has_key?(name)
  end

  def clear_hooks(name)
    @hooks.delete(name)
  end
end
