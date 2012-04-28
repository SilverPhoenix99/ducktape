module Ducktape
  class BindingSource
    PROPAGATE_TO_SOURCE  = [:reverse, :both].freeze
    PROPAGATE_TO_TARGETS = [:forward, :both].freeze

    attr_reader :source # BindableAttribute
    attr_accessor :mode # :forward, :reverse, :both

    def initialize(source, source_attr, mode = :both)
      set_source(source, source_attr)
      @mode = mode
    end

    private

    #TODO: notify source/target of change
    def set_source(source, source_attr)
      @source = source.send(:get_bindable_attr, source_attr)
    end
  end
end