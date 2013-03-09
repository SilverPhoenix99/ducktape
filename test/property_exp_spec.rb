require_relative 'test_helper'

include Ducktape

class Address
  include Ducktape::Bindable

  bindable :street, validate: [String, nil]
  bindable :po_box, validate: [Integer, nil]

  def to_s
    "<Address @street = #{street.inspect} ; @po_box = #{po_box.inspect}>"
  end
end

class Person
  include Ducktape::Hookable

  attr_accessor :name, :address
  make_hooks :name= => :change_name, :address= => :change_address

  def to_s
    "<Person @name = #{name.inspect} ; address = #{address.inspect}>"
  end
end

describe Expression::PropertyExp do
  before :each do
    @addr1 = Address.new.tap do |a|
      a.street = 'abc'
      a.po_box = 123
    end

    @addr2 = Address.new.tap do |b|
      b.street = 'cde'
      b.po_box = 456
    end

    @person = Person.new.tap do |p|
      p.name = 'xyz'
      p.address = @addr1
    end
  end


  it 'should have equal streets' do
    @addr2.street = BindingSource.new(@person, 'address.street')
    @addr2.street.should == @addr1.street
  end

  it 'should propagate to source' do
    @addr2.street = BindingSource.new(@person, 'address.street')
    @addr2.street = 'foo bar'
    @addr1.street.should == 'foo bar'
  end
end