module Ducktape
  class HookableArray
    include HookableCollection

    def self.[](*args)
      new([*args])
    end

    def self.try_convert(obj)
      return obj if obj.is_a? self
      obj = Array.try_convert(obj)
      obj ? new(obj) : nil
    end

    # Careful when duping arrays. Duping is shallow.
    def initialize(*args, &block)
      @content = if args.length == 1
        arg = args[0]
        case
          when arg.is_a?(Array) then arg.dup
          when arg.is_a?(HookableArray) then arg.instance_variable_get('@content').dup
          when arg.is_a?(Enumerable) || arg.respond_to?(:to_a) then arg.to_a
        end
      end || Array.new(*args, &block)
    end

    def to_a() self end
    def to_ary() self end

    def ==(other)
      other = Array.try_convert(other)
      return false unless other || other.count != self.count
      enum = other.each
      each { |v1| return false unless v1 == enum.next }
      true
    end

    compile_hooks(
      %w'clear
      collect!
      compact!
      concat
      delete
      delete_at
      delete_if
      fill
      flatten!
      insert
      keep_if
      map!
      pop
      push
      reject!
      replace
      reverse!
      rotate!
      select!
      shift
      shuffle!
      slice!
      sort!
      sort_by!
      uniq!
      unshift',
      '<<'  => 'append',
      '[]=' => 'store'
    )
  end
end