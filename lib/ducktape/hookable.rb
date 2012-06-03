module Ducktape
  module Hookable

    module ClassMethods
      def def_hook(*events)
        events.each { |e| define_method e, ->(method_name = nil, &block){ add_hook(e, method_name, &block) } }
      end

      %w'hook handler'.each do |type|
        define_method "make_#{type}s" do |*args|
          return if args.length == 0

          #def_hook 'on_changed' unless method_defined?('on_changed')

          names_hash = args.pop if args.last.is_a?(Hash)
          names_hash ||= {}

          #Reversed merge because names_hash has priority.
          names_hash = Hash[args.flatten.map { |v| [v, v] }].merge!(names_hash)

          names_hash.each do |name, aka|
            aka = "on_#{aka}"
            def_hook(aka) unless method_defined?(aka)

            um = public_instance_method(name)
            cm = "call_#{type}s"
            define_method(name) do |*a, &block|
              bm = um.bind(self)
              r = bm.(*a, &block)
              if !send(cm,          aka, self, event: name, args: a, result: r) || type != 'handler'
                send(  cm, 'on_changed', self, event: name, args: a, result: r)
              end
              r
            end
          end
        end
      end
    end

    def self.included(base)
      base.extend(ClassMethods)
      base.def_hook :on_changed unless base.method_defined? :on_changed
    end

    def self.extended(_)
      raise 'Cannot extend, only include.'
    end

    def add_hook(event, hook = nil, &block)
      hook = block if block #block has precedence
      return unless hook
      hook = hook.to_s unless hook.respond_to?('call')
      self.hooks[event.to_s].unshift(hook)
      hook
    end

    def remove_hook(event, hook)
      hook = hook.to_s unless hook.respond_to?('call')
      self.hooks[event.to_s].delete(hook)
    end

    def clear_hooks(event = nil)
      if event
        self.hooks.delete(event.to_s)
      else
        self.hooks.clear.dup
      end
    end

    protected #--------------------------------------------------------------

    def hooks
      @hooks ||= Hash.new { |h,k| h[k.to_s] = [] }
    end

    # `#call_handlers` is similar to `#call_hooks`,
    # but stops calling other hooks when a hook returns a value other than nil or false.
    %w'hook handler'.each do |type|
      define_method("call_#{type}s", ->(event, caller = self, parms = {}) do
        return unless self.hooks.has_key? event.to_s
        self.hooks[event.to_s].each do |hook|
          hook = caller.method(hook) unless hook.respond_to?('call')
          handled = hook.(event, caller, parms)
          break handled if type == 'handler' && handled
        end
      end)
    end
  end
end