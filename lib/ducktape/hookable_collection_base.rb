module Ducktape
  class HookableCollectionBase
    include Hookable

    attr_reader :content

    def method_missing(name, *args, &block)
      @content.public_send(name, *args, &block)
    end

    def to_s() @content.to_s end
    def inspect() @content.inspect end
    def hash() @content.hash end
    def dup() self.class.new(@content) end

    def_hook 'on_changed'

    class << self
      private
      def compile_hooks(names_ary, names_hash = {}, &block)

        names_hash = names_hash.merge( Hash[names_ary.map { |v| [v, v] }] )
        names_hash = Hash[ names_hash.map { |name, aka| [name, "on_#{aka}"] } ]

        names_hash.each do |name, aka|
          def_hook(aka) unless method_defined?(aka)

          define_method(name) do |*args, &arg_block|
            result = @content.public_send(__method__, *args, &arg_block)
            call_hooks(aka, self, args, result)
            call_hooks('on_changed', self, name, args, result)
            return block.(result) if block
            result
          end
        end

        nil
      end

      def wrap(names_ary, names_hash, &block)
        names_hash.merge(Hash[names_ary.map { |v| [v, v] }]).each do |name|
          define_method(name) do |*args, &arg_block|
            v = @content.public_send(name, *args, &arg_block)
            block.(v)
          end
        end
      end
    end
  end
end