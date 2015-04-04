require_relative 'test_helper'

include Ducktape

RSpec.instance_eval do

  describe Expression::IndexerExp do

    let(:Names) do
      Class.new do
        include Bindable

        bindable :names, default: Ducktape.hookable([])
      end
    end

    let(:SimpleBindable) do
      Class.new do
        include Bindable

        bindable :name
      end
    end

    let(:src) do
      Names().new.tap do |src|
        src.names.push :a, :b, :c
      end
    end

    let(:tgt) do
      SimpleBindable().new.tap do |tgt|
        tgt.bind :name, src, 'names[0]'
      end
    end

    subject { tgt }

    it { should have_attributes(name: :a) }

    describe 'update' do
      it do
        src.names[0] = :d
        should have_attributes(name: :d)
      end
    end
  end

end