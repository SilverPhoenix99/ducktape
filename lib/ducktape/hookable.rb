module Ducktape
  module Hookable
    def self.included(base)
      if base.is_a?(Class)
        base.include InstanceMethods
        base.extend  ClassMethods
        base.def_hook(:on_changed) unless base.method_defined?(:on_changed)
        return
      end

      # Module

      # just create a proxy for #included
      include_method = if base.respond_to?(:included)
        base_included_method = base.method(:included)
        ->(c) do
          base_included_method.(c)
          c.send :include, ::Ducktape::Hookable
        end
      else
        ->(c) { c.send :include, ::Ducktape::Hookable }
      end

      base.define_singleton_method(:included, include_method)
    end

    def self.extended(_)
      raise 'Cannot extend, only include.'
    end

    module ClassMethods

      # Creates a wrapper method for #add_hook that doesn't require the event to be passed.
      # For example, calling:
      #
      #    def_hook :on_init
      #
      # will create a +on_init+ method, that can be used as:
      #
      #    on_init { |*_| puts 'I initialized' }
      #
      # It's the same as calling:
      #
      #    add_hook(:on_init) { |*_| puts 'I initialized' }
      #
      def def_hook(event)
        define_method event, ->(method_name = nil, &block) do
          add_hook event, method_name, &block
        end
      end

      # Calls +def_hook+ for each event passed.
      def def_hooks(*events)
        events.each { |event| def_hook(event) }
      end

      # Overrides (decorates) existing methods to make then hookable.
      def make_hooks(*args)
        make :hook, *args
      end

      # Overrides (decorates) existing methods to make then handleable.
      # This is similar to hookable, but stops calling the hooks
      # when a hook returns +false+ or +nil+.
      def make_handlers(*args)
        make :handler, *args
      end

      private

        def make(type, *args)
          return if args.length == 0

          build_hook_names(args).each do |method_name, event|
            hook_name = "on_#{event}"
            def_hook(hook_name) unless method_defined?(hook_name)
            original_method = public_instance_method(method_name)
            decorate_method type, original_method, hook_name
          end
        end

        def build_hook_names(args)
          hook_names = args.extract_options!

          #Reversed merge because hook_names has priority.
          Hash[args.flatten.map { |v| [v, v] }].merge!(hook_names)
        end

        def decorate_method(type, original_method, hook_name)
          define_method(original_method.name) do |*args, &block|
            bound_method = original_method.bind(self)
            result = bound_method.(*args, &block)
            params = OpenStruct.new(args: args, result: result)
            call_name = "call_#{ type }s"
            result = send(call_name, hook_name, original_method.name, params)
            unless result && type == :handler
              # invoke if previous call is false or nil
              send call_name, :on_changed, original_method.name, params
            end
            result
          end
        end
    end

    module InstanceMethods

      # Registers a block, a named method, or any object that responds to +call+
      # to be triggered when the +event+ occurs.
      def add_hook(event, hook = nil, &block)
        hook = block if block #block has precedence
        raise ArgumentError, 'no hook was passed' unless hook
        hook = hook.to_s unless hook.respond_to?(:call)
        hooks[event.to_s].unshift(hook)
        hook
      end

      # Removes the specified hook. Returns +nil+ if the hook wasn't found.
      def remove_hook(event, hook)
        return unless hooks.has_key?(event.to_s)
        hook = hook.to_s unless hook.respond_to?(:call)
        hooks[event.to_s].delete(hook)
      end

      # Removes all hooks from the specified +event+.
      # If an +event+ wasn't passed, removes all hooks from all events.
      def clear_hooks(event = nil)
        if event
          hooks.delete(event.to_s) if hooks.has_key?(event.to_s)
          return
        end

        hooks.clear
        nil
      end

      private #--------------------------------------------------------------

        def hooks
          @hooks ||= Hash.new { |h, k| h[k.to_s] = [] }
        end

        def extract_parameters(args)
          raise ArgumentError, "wrong number of arguments (#{args.length} for 0..2)" if args.length > 2

          case
            when args.length == 0                               # call_*s(event, caller = self, parms = {})
              [self, {}]
            when args.length == 2                               # call_*s(event, caller, parms)
              args
            when [Hash, OpenStruct].include?(args[0].class)     # call_*s(event, caller = self, parms)
              [self, args[0]]
            else
              [args[0], {}]                                     # call_*s(event, caller, parms = {})
          end
        end

        def build_hook(hook)
          case hook
            when Proc, Method then hook
            when Symbol, String then caller.method(hook)
            else hook.method(:call)
          end
        end

        def call_hook(hook, event, caller, parms, parms2)
          return hook.(), parms2 if hook.arity == 0
          return hook.(event, caller, parms) if hook.arity > 1

          parms = parms.to_h if parms.is_a?(OpenStruct)
          parms2 ||= OpenStruct.new(parms.merge(event: event, caller: caller))
          [ hook.(parms2), parms2 ]
        end

        def call_hooks(event, *args)
          invoke :hook, event, *args
        end

        # `#call_handlers` is similar to `#call_hooks`,
        # but stops calling other hooks when a hook returns a value other than +nil+ or +false+.
        # If caller is a Hash, then use: call_*s(event, hash, {})
        def call_handlers(event, *args)
          invoke :handler, event, *args
        end

        def invoke(type, event, *args)
          caller, parms = extract_parameters(args)
          return unless hooks.has_key?(event.to_s)
          handled, parms2 = nil, nil
          hooks[event.to_s].each do |hook|
            hook = build_hook(hook)
            handled, parms2 = call_hook(hook, event, caller, parms, parms2)
            break if type == :handler && handled
          end
          type == :handler && handled
        end
    end
  end
end