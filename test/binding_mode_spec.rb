require_relative 'test_helper'

include Ducktape

class X
  include Bindable

  bindable :name, validate: [String, nil]

  def initialize(name = nil)
    self.name = name
  end
end

RSpec.describe Expression::IdentifierExp do
  before do
    @src = X.new('abc')
    @tgt = X.new
  end

  describe 'both binding' do
    before do
      @tgt.name = BindingSource.new(@src, :name)
      @src.name = 'cde'
    end

    it { @tgt.name.should == 'cde' }

    it { @tgt.name.should == @src.name }

  end

  describe 'forward binding' do
    before do
      @tgt.name = BindingSource.new(@src, :name, :forward)
    end

    it 'should have different names' do
      @src.name = 'abc'
      @tgt.name = 'aabb'
      @tgt.name.should == 'aabb'
      @tgt.name.should_not == @src.name
    end

    it 'should have equal names' do
      @tgt.name = 'xxyy'
      @src.name = 'cde'
      @tgt.name.should == 'cde'
      @tgt.name.should == @src.name
    end
  end

  describe 'reverse binding' do
    before :all do
      @tgt.name = Ducktape::BindingSource.new(@src, :name, :reverse)
    end

    it 'should have different names' do
      @tgt.name = 'qwer'
      @src.name = 'mno'
      @tgt.name.should == 'qwer'
      @tgt.name.should_not == @src.name
    end

    it 'should have equal names' do
      @src.name = 'rfv'
      @tgt.name = 'cdd'
      @src.name.should == 'cdd'
      @tgt.name.should == @src.name
    end
  end
end
