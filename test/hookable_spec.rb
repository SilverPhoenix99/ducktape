require_relative 'test_helper'

include Ducktape

RSpec.instance_eval do

  shared_examples_for 'a hookable module' do |obj|
    subject &obj
    it { should respond_to(:included) }

    it { should respond_to(:def_hook) }
    it { should respond_to(:def_hooks) }
    it { should respond_to(:make_hooks) }
    it { should respond_to(:make_handlers) }

    it { should_not have_instance_method(:add_hook) }
    it { should_not have_instance_method(:remove_hook) }
    it { should_not have_instance_method(:clear_hooks) }
  end

  shared_examples_for 'a hookable class' do |obj|
    subject &obj
    it { should_not respond_to(:included) }

    it { should respond_to(:def_hook) }
    it { should respond_to(:def_hooks) }
    it { should respond_to(:make_hooks) }
    it { should respond_to(:make_handlers) }

    it { should have_instance_method(:add_hook) }
    it { should have_instance_method(:remove_hook) }
    it { should have_instance_method(:clear_hooks) }
  end

  describe Hookable do

    let(:m1)   { Module.new { include Hookable } }
    let(:m1_1) { m = self.m1; Module.new { include m } }
    let(:m1_2) { m = self.m1; Module.new { extend  m } }
    let(:c2)   { Class.new { include Hookable } }
    let(:c3)   { m = self.m1_1; Class.new { include m } }

    describe(:m1)   { it_behaves_like 'a hookable module', proc { m1 } }
    describe(:m1_1) { it_behaves_like 'a hookable module', proc { m1_1 } }

    describe :m1_2 do
      subject { m1_2 }

      it { should_not respond_to(:included) }

      it { should_not respond_to(:def_hook) }
      it { should_not respond_to(:def_hooks) }
      it { should_not respond_to(:make_hooks) }
      it { should_not respond_to(:make_handlers) }

      it { should_not have_instance_method(:add_hook) }
      it { should_not have_instance_method(:remove_hook) }
      it { should_not have_instance_method(:clear_hooks) }
    end

    describe(:c2) { it_behaves_like 'a hookable class', proc { c2 } }
    describe(:c3) { it_behaves_like 'a hookable class', proc { c3 } }

    describe 'instance' do
      before do
        @count = 1
        c3.def_hook :on_init
        c3.send(:define_method, :init) do
          call_hooks :on_init
        end
      end

      subject { c3.new.tap { |c| c.on_init { @count += 1 } } }

      it { should respond_to(:add_hook) }
      it { should respond_to(:remove_hook) }
      it { should respond_to(:clear_hooks) }

      it { should respond_to(:on_init) }
      it { should respond_to(:on_changed) }

      it { expect { subject.init }.to change { @count }.by(1) }
      it { expect { 2.times { subject.init } }.to change { @count }.by(2) }

    end
  end

end