require_relative 'test_helper'
require_relative '../lib/ducktape/bindable/binding_source'

# noinspection RubyConstantNamingConvention
BindingSource = Ducktape::Bindable::BindingSource

RSpec.describe BindingSource do

  let(:attr_name) { :attr_name_1 }

  let(:value) { Object.new }

  let(:attribute) do
    double('attr').tap do |attr|
      allow(attr).to receive(:value).and_return(value)
    end
  end

  let(:source) do
    double('source').tap do |src|
      allow(src).to receive(:instance_variable_get).with(:"@#{attr_name}").and_return(attribute)
    end
  end

  subject { BindingSource.new(source, attr_name) }

  describe '#direction' do

    it 'is both' do
      expect(subject.direction).to eq :both
      expect(subject).to be_forward
      expect(subject).to be_reverse
    end

    it 'is forward' do
      binding_source = BindingSource.new(nil, :x, direction: :forward)
      expect(binding_source.direction).to eq :forward
      expect(binding_source).to be_forward
      expect(binding_source).to_not be_reverse
    end

    it 'is reverse' do
      binding_source = BindingSource.new(nil, :x, direction: :reverse)
      expect(binding_source.direction).to eq :reverse
      expect(binding_source).to_not be_forward
      expect(binding_source).to be_reverse
    end

  end

  describe '#source_value' do

    it "returns the converted value of the source's attribute" do
      binding_source = BindingSource.new(source, attr_name) { |val, direction| [val, direction] }
      expect(binding_source.source_value).to eq [value, :forward]
    end

  end

  describe '#unbind' do

    it 'removes the hooks' do

      target = double('target')

      expect(attribute).to receive(:remove_hook).with(:on_changed, subject)
      expect(target).to receive(:remove_hook).with(:on_changed, subject)

      subject.unbind target
    end

  end

  describe '#bind' do

    it 'adds the hooks' do
      target_value = Object.new

      expect(attribute).to receive(:value=).with(target_value)
      expect(attribute).to(receive(:on_changed).with(subject)) { |&hook| hook.() }

      target = double('target')
      allow(target).to receive(:value).and_return(target_value)
      expect(target).to receive(:value=).with(value)
      expect(target).to(receive(:on_changed).with(subject)) { |&hook| hook.() }

      subject.bind(target)
    end

  end

end
