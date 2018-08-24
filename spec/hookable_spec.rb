require_relative 'test_helper'
require_relative '../lib/ducktape/hookable'

include Ducktape

RSpec.describe Hookable do

  let(:hook) { proc { } }

  let(:hookable_type) do
    Class.new do
      include Hookable

      def_hooks :on_test, :on_2nd_test

      def hook_method(*)
      end
    end
  end

  subject { hookable_type.new }

  describe '::def_hook' do
    subject { hookable_type }

    it { is_expected.to have_instance_method(:on_test) }
  end

  describe '::def_hooks' do

    subject do
      hookable_type.tap do |type|
        type.instance_eval do
          def_hooks :test_hook1, :test_hook2
        end
      end
    end

    it { is_expected.to have_instance_method(:test_hook1, :test_hook2) }

  end

  describe '#add_hook' do

    example 'without proc and block arguments' do
      expect { subject.add_hook(:on_test) }.to raise_error(ArgumentError)
    end

    example 'with both proc and block arguments' do
      expect { subject.add_hook(:on_test, hook, &hook) }.to raise_error(ArgumentError)
    end

    it 'has an overload for procs' do
      expect(subject).to receive(:add_hook).with(:on_test, hook).and_call_original
      subject.on_test hook
    end

    it 'has an overload for blocks' do
      expect(subject).to receive(:add_hook).with(:on_test, nil).and_wrap_original do |m, *args, &hook_block|
        expect(hook_block).to be_a Proc
        m.call(*args, &hook_block)
      end

      subject.on_test &hook
    end

    it 'has an overload for named blocks' do
      expect(subject).to receive(:add_hook).with(:on_test, :block_name).and_wrap_original do |m, *args, &hook_block|
        expect(hook_block).to be_a Proc
        m.call(*args, &hook_block)
      end

      subject.on_test :block_name, &hook
    end

    it 'has an overload for method names' do
      expect(subject).to receive(:add_hook).with(:on_test, :test_method).and_call_original
      subject.on_test :test_method
    end
  end

  describe '#call_hook' do

    context 'with proc' do
      it 'calls the hook proc' do
        expect(hook).to receive(:call).with(sender: subject)

        subject.add_hook :on_test, hook
        subject.send :call_hook, :on_test
      end

      it 'calls the hook block' do
        expect(hook).to receive(:call).with(sender: subject)

        subject.add_hook :on_test, &hook
        subject.send :call_hook, :on_test
      end
    end

    context 'with method name' do
      it 'accepts Symbols' do
        expect(subject).to receive(:hook_method).with(sender: subject)

        subject.add_hook :on_test, :hook_method
        subject.send :call_hook, :on_test
      end

      it 'accepts Strings' do
        expect(subject).to receive(:hook_method).with(sender: subject)

        subject.add_hook 'on_test', 'hook_method'
        subject.send :call_hook, 'on_test'
      end
    end
  end

  describe '#remove_hook' do
    it "doesn't call the removed method hook" do
      expect(subject).to_not receive(:hook_method)

      subject.add_hook :on_test, :hook_method
      subject.remove_hook :on_test, :hook_method

      subject.send :call_hook, :on_test
    end

    it "doesn't call the removed named block hook" do
      expect(hook).to_not receive(:call)

      subject.add_hook :on_test, :block_name, &hook
      subject.remove_hook :on_test, :block_name

      subject.send :call_hook, :on_test
    end

    it "doesn't call the removed block hook" do
      expect(hook).to_not receive(:call)

      subject.add_hook :on_test, &hook
      subject.remove_hook :on_test, hook

      subject.send :call_hook, :on_test
    end
  end

  describe '#remove_hooks' do
    it 'removes all hooks associated with the specified name' do
      expect(subject).to_not receive :hook_method
      expect(hook).to receive :call

      subject.add_hook :on_test, :hook_method
      subject.add_hook :on_2nd_test, hook
      subject.remove_hooks :on_test

      subject.send :call_hook, :on_test
      subject.send :call_hook, :on_2nd_test
    end
  end

  describe '#clear_hooks' do
    it 'removes all hooks' do
      expect(subject).to_not receive :hook_method
      expect(hook).to_not receive :call

      subject.add_hook :on_test, :hook_method
      subject.add_hook :on_2nd_test, hook
      subject.clear_hooks

      subject.send :call_hook, :on_test
      subject.send :call_hook, :on_2nd_test
    end
  end
end
