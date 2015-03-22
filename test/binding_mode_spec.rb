require_relative 'test_helper'

include Ducktape

class X
  include Bindable

  bindable :name, validate: [String, nil]

  def initialize(name = nil)
    self.name = name
  end
end

RSpec.instance_eval do

  describe Expression::IdentifierExp do

    let(:src) { X.new('abc') }
    let(:tgt) { X.new }

    subject { tgt }

    describe 'both binding' do
      before do
        tgt.bind :name, src, :name
        src.name = 'cde'
      end

      it { should have_attributes(name: 'cde') }
      it { should have_attributes(name: src.name) }
    end

    describe 'forward binding' do
      before do
        tgt.bind :name, src, :name, :forward
      end

      subject { tgt }

      describe do
        before do
          src.name = 'abc'
          tgt.name = 'aabb'
        end

        it { should have_attributes(name: 'aabb') }
        it { should_not have_attributes(name: src.name) }
      end

      describe do
        before do
          tgt.name = 'xxyy'
          src.name = 'cde'
        end

        it { should have_attributes(name: 'cde') }
        it { should have_attributes(name: src.name) }
      end
    end

    describe 'reverse binding' do
      before do
        tgt.bind :name, src, :name, :reverse
      end

      describe do
        before do
          tgt.name = 'qwer'
          src.name = 'mno'
        end

        it { should have_attributes(name: 'qwer') }
        it { should_not have_attributes(name: src.name) }
      end

      describe do
        before do
          src.name = 'rfv'
          tgt.name = 'cdd'
        end

        it { should have_attributes(name: 'cdd') }
        it { should have_attributes(name: src.name) }
      end
    end
  end
end

