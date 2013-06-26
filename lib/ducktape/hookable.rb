module Ducktape
  module Hookable

    module ClassMethods
      def def_hook(*events)
        events.each { |e| define_method e, ->(method_name = nil, &block) { add_hook(e, method_name, &block) } }
      end

      %w'hook handler'.each do |type|
        define_method "make_#{type}s" do |*args|
          return if args.length == 0

          names_hash = (args.last.is_a?(Hash) && args.pop) || {}

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
              if !send(cm, aka,         name, OpenStruct.new(args: a, result: r)) || type != 'handler'
                send(  cm, :on_changed, name, OpenStruct.new(args: a, result: r))
              end
              r
            end
          end
        end
      end
    end

    def self.included(base)
      base.extend(ClassMethods)
      base.def_hook :on_changed unless base.method_defined?(:on_changed)
      return unless base.is_a?(Module)
      included = base.respond_to?(:included) && base.method(:included)
      base.define_singleton_method(:included, ->(c) do
        included.(c) if included
        c.extend(ClassMethods)
      end)
    end

    def self.extended(_)
      raise 'Cannot extend, only include.'
    end

    def add_hook(event, hook = nil, &block)
      hook = block if block #block has precedence
      raise ArgumentError, 'no hook was passed' unless hook
      hook = hook.to_s unless hook.respond_to?(:call)
      self.hooks[event.to_s].unshift(hook)
      hook
    end

    def remove_hook(event, hook)
      hook = hook.to_s unless hook.respond_to?(:call)
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
    # If caller is a Hash, then use: call_*s(event, hash, {})
    %w'hook handler'.each do |name|
      define_method("call_#{name}s", ->(event, *args) do
        raise ArgumentError, "wrong number of arguments (#{args.length} for 3)" if args.length > 2
        caller, parms = case
          when args.length == 0 then [self, {}]                                    # call_*s(event, caller = self, parms = {})
          when args.length == 2 then args                                          # call_*s(event, caller, parms)
          when [Hash, OpenStruct].any? { |c| c === args[0] } then [self, args[0]]  # call_*s(event, caller = self, parms)
          else [args[0], {}]                                                       # call_*s(event, caller, parms = {})
        end

        return unless hooks.has_key?(event.to_s)

        handled, parms2 = nil, nil
        hooks[event.to_s].each do |hook|
          hook = case hook
            when Proc, Method then hook
            when Symbol, String then caller.method(hook)
            else hook.method(:call)
          end
          handled = if hook.arity == 0
                      hook.()
                    elsif hook.arity == 1
                      parms2 ||= OpenStruct.new(
                        (parms.is_a?(OpenStruct) ? parms.to_h : parms).merge(event: event, caller: caller))
                      hook.(parms2)
                    else
                      hook.(event, caller, parms)
                    end
          break if name.index('handler') && handled
        end
        name.index('handler') && handled
      end)
    end
  end
end