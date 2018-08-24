require_relative '../ducktape'

class ::Exception
  attr_reader :context

  alias_method :_base_initialize, :initialize

  def initialize(msg = nil, **context)
    @context = context
    _base_initialize msg
  end

  alias_method :_base_to_s, :to_s
  private :_base_to_s

  def to_s
    msg = _base_to_s
    if !@context&.any?
      msg
    elsif msg.empty?
      @context.inspect
    else
      "#{msg} : #{context.inspect}"
    end
  end

  def inspect
    msg = to_s
    msg.empty? ? self.class.name : "#<#{self.class.name} : #{msg}>"
  end
end
