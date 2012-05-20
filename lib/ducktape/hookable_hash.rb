module Ducktape
  class HookableHash
    include HookableCollection

    def self.[](*args)
      new(Hash[*args])
    end

    def self.try_convert(obj)
      return obj if obj.is_a? self
      obj = Hash.try_convert(obj)
      obj ? new(obj) : nil
    end

    # Careful with duping hashes. Duping is shallow.
    def initialize(*args, &block)
      @content = if args.length == 1
        arg = args[0]
        case
          when arg.is_a?(Hash) then arg.dup
          when arg.is_a?(HookableHash) then arg.instance_variable_get('@hash').dup
          when arg.respond_to?(:to_hash) then arg.to_hash
        end
      end || Hash.new(*args, &block)
    end

    def to_hash() self end

    def ==(other)
      other = Hash.try_convert(other)
      return false unless other || other.count != self.count
      enum = other.each
      each { |v1| return false unless v1 == enum.next }
      true
    end

    compile_hooks(
      %w'clear
      default=
      default_proc=
      delete
      delete_if
      keep_if
      merge!
      rehash
      reject!
      replace
      select!
      shift
      store
      update',
      '[]=' => 'store'
    )
  end
end