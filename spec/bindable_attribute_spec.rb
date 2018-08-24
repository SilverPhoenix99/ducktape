require_relative 'test_helper'
require_relative '../lib/ducktape/bindable/attribute'

RSpec.describe Ducktape::Bindable::Attribute do

  # noinspection RubyConstantNamingConvention
  Attribute = Ducktape::Bindable::Attribute

  describe '::build_subclass' do

    it 'only subclasses from Attribute' do
      expect { Attribute.build_subclass(Object) }.to raise_error Ducktape::InvalidTypeError
    end

    it 'requires a name' do
      expect { Attribute.build_subclass }.to raise_error Ducktape::UnnamedError
    end

    it "gives an error with invalid options" do
      expect { Attribute.build_subclass(invalid: :option) }.to raise_error Ducktape::UnknownOptionError
    end

    subject { Attribute.build_subclass(name: :attr_name) }

    it 'has a name' do
      expect(subject.name).to eq :attr_name
    end

    it 'inherits attributes from the base class' do
      expect(subject.default).to equal Attribute.default
      expect(subject.getter).to equal Attribute.getter
      expect(subject.setter).to equal Attribute.setter
      expect(subject.validators).to equal Attribute.validators
    end

    it "doesn't allow the name to be overriden" do
      expect { Attribute.build_subclass(subject, name: :"#{subject.name}_2") }.to raise_error Ducktape::AlreadyNamedError
    end

    it 'requires at least one validator' do
      expect { Attribute.build_subclass(subject, name: :attr_name, validate: []) }.to raise_error Ducktape::EmptyValidatorsError
    end

  end

  describe '::default' do

    it 'creates a new default proc' do
      sub = Attribute.build_subclass(name: :attr_name, default: nil)
      expect(sub.default).to_not equal Attribute.default
      expect(sub.default).to be_a Proc
      expect(sub.default.()).to be_nil
    end

    it 'sets the default proc' do
      dft_value = 'dft_value_1'
      sub = Attribute.build_subclass(name: :attr_name, default: proc { dft_value })
      expect(sub.default.()).to equal dft_value
    end

  end

  describe '::getter' do

    it 'is set' do
      prefix = 'str_value_'
      suffix = '100'
      sub = Attribute.build_subclass(name: :attr_name, getter: ->(v) { v + suffix })
      expect(sub.getter.(prefix)).to eq prefix + suffix
    end

    it 'must be callable' do
      expect { Attribute.build_subclass(name: :attr_name, getter: false) }.to raise_error Ducktape::AccessorError
    end

  end

  describe '::setter' do

    it 'is set' do
      prefix = 'str_value_'
      suffix = '100'
      sub = Attribute.build_subclass(name: :attr_name, setter: ->(v) { v + suffix })
      expect(sub.setter.(prefix)).to eq prefix + suffix
    end

    it 'must be callable' do
      expect { Attribute.build_subclass(name: :attr_name, setter: false) }.to raise_error Ducktape::AccessorError
    end

  end

  describe '::validators' do

    it 'changes nil into an array' do
      sub = Attribute.build_subclass(name: :attr_name, validate: nil)
      expect(sub.validators).to eq [nil]
    end

    it 'changes non-array value into an array' do
      sub = Attribute.build_subclass(name: :attr_name, validate: Integer)
      expect(sub.validators).to eq [Integer]
    end

  end

  let(:owner) { Object.new }

  describe '#value' do

    it 'applies the getter' do

      value = 'some val'
      getter = proc { |val| val + ' 2' }

      sub = Attribute.build_subclass(name: :test_attr, getter: getter)
      attr = sub.new(owner, value: value)


      expect(owner).to receive(:instance_exec).with(value).and_call_original
      expect(attr.value).to eq getter.(value)
    end

  end

  describe '#value=' do

    it 'calls hooks when the value changes' do

      sub = Attribute.build_subclass(name: :test_attr)
      attr = sub.new(owner, value: 'some value')

      expect(attr).to receive :call_hook

      attr.value = :some_other_value
    end

    it "doesn't call the hooks if the value didn't change" do

      sub = Attribute.build_subclass(name: :test_attr)
      attr = sub.new(owner, value: 'some value')

      expect(attr).to_not receive :call_hook

      attr.value = 'some value'
    end

    it 'validates the value' do

      sub = Attribute.build_subclass(name: :test_attr, validate: [Integer, :special_value])

      expect{ sub.new(owner, value: 'some value') }.to raise_error Ducktape::InvalidValueError

      attr = sub.new(owner, value: 123)
      expect(attr.value).to eq 123

      expect { attr.value = 'abc' }.to raise_error Ducktape::InvalidValueError

      attr.value = 567
      expect(attr.value).to eq 567

      attr.value = :special_value
      expect(attr.value).to eq :special_value
    end

    it 'binds the source' do

      sub = Attribute.build_subclass(name: :test_attr)
      attr = sub.new(owner, value: 101)

      value = 'some value'

      src = instance_double(Ducktape::Bindable::BindingSource.name)
      allow(src).to receive(:forward?).and_return(true)
      allow(src).to receive(:is_a?).with(Ducktape::Bindable::BindingSource).and_return(true)
      expect(src).to receive(:bind).with(attr)
      expect(src).to receive(:source_value).and_return(value)

      expect(attr).to receive(:source=).with(src).and_call_original
      expect(attr).to receive(:value=).with(src).and_call_original
      expect(attr).to receive(:value=).with(value).and_call_original

      attr.value = src

      expect(attr.value).to equal value
    end

    it 'replaces the source' do

      sub = Attribute.build_subclass(name: :test_attr)
      attr = sub.new(owner, value: 101)

      value = 'some value'

      src = instance_double(Ducktape::Bindable::BindingSource.name).as_null_object
      allow(src).to receive(:forward?).and_return(true)
      allow(src).to receive(:is_a?).with(Ducktape::Bindable::BindingSource).and_return(true)
      allow(src).to receive(:source_value).and_return(nil)

      attr.value = src

      src2 = instance_double(Ducktape::Bindable::BindingSource.name).as_null_object
      allow(src2).to receive(:forward?).and_return(true)
      allow(src2).to receive(:is_a?).with(Ducktape::Bindable::BindingSource).and_return(true)
      allow(src2).to receive(:source_value).and_return(value)

      expect(src).to receive(:unbind).with(attr)
      expect(src2).to receive(:bind).with(attr)

      attr.value = src2

      expect(attr.value).to equal value
    end

  end

end
