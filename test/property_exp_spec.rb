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

RSpec.instance_eval do

  describe Expression::PropertyExp do

    let(:addr1) do
      Address.new.tap do |a|
        a.street = 'abc'
        a.po_box = 123
      end
    end

    let(:addr2) do
      Address.new.tap do |b|
        b.street = 'cde'
        b.po_box = 456
      end
    end

    let(:person) do
      Person.new.tap do |p|
        p.name = 'xyz'
        p.address = addr1
      end
    end

    describe do
      before { addr2.bind :street, person, 'address.street' }

      specify { expect(addr2.street).to be == addr1.street }

      describe 'propagates to source' do
        before { addr2.street = 'foo bar' }

        specify { expect(addr1.street).to be == 'foo bar' }
      end
    end
  end

end