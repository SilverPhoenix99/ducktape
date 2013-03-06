module Ducktape
  module Expression
    class UnboundError < StandardError; end

    class BindingParser < Whittle::Parser
      %w':: . , [ ]'.each { |op| rule(op) }

      rule(number: /[0-9]+/).as { |v| IntegerExp.new(Integer(v)) }
      rule(id:     /[a-zA-Z_]\w*/).as { |v| IdentifierExp.new(v) }
      rule(symbol: /:[a-zA-Z_]\w*/).as { |v| SymbolExp.new(v[1,v.length].to_sym) }

      rule(:qual) do |r|
        r[:indexer, '::', :expr].as { |l, _, r| QualifiedExp.new(l, r) }
        r[:id,      '::', :expr].as { |l, _, r| QualifiedExp.new(l, r) }
      end

      rule(:property) do |r|
        r[:indexer, '.', :expr].as { |l, _, r| PropertyExp.new(l, r) }
        r[:id,      '.', :expr].as { |l, _, r| PropertyExp.new(l, r) }
      end

      rule(:params) do |r|
        r[:params, ',', :expr].as   { |params, _, v| params << v }
        r[:params, ',', :symbol].as { |params, _, v| params << v }
        r[:params, ',', :number].as { |params, _, v| params << v }
        r[:expr].as                 { |v| [v] }
        r[:symbol].as               { |v| [v] }
        r[:number].as               { |v| [v] }
      end

      rule(:indexer) do |r|
        r[:indexer, '[', :params, ']'].as { |l, _, r, _| IndexerExp.new(l, r) }
        r[:id,      '[', :params, ']'].as { |l, _, r, _| IndexerExp.new(l, r) }
      end

      rule(:expr) do |r|
        r[:qual]
        r[:property]
        r[:indexer]
        r[:id]
      end

      start :expr

      def self.parse(input, options = {})
        new.parse(input.to_s, options)
      end
    end
  end
end