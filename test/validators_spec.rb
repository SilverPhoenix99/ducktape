require_relative 'test_helper'

include Ducktape

RSpec.instance_eval do

  describe Bindable do

    let(:Foo) do
      Class.new do
        include Bindable

        bindable :name, validate: [String, Symbol], default: ''
        bindable :enum, validate: [:first, :second, nil]
        bindable :ranking, validate: 0..5, default: 0
        bindable :identifier, validate: /\d+/, default: '0'
        bindable :even, validate: [nil, ->(value) { value % 2 == 0 }]

        def initialize(ranking)
          self.ranking = ranking
        end
      end
    end

    let(:Bar) do
      Class.new(Foo()) do
        bindable :enum, default: :second
      end
    end

    describe 'validation' do

      subject { Foo().new(0) }

      specify { expect { subject.name = 1 }.to raise_error(InvalidAttributeValueError) }
      specify { expect { subject.name = '1' }.not_to raise_error }
      specify { expect { subject.name = :one }.not_to raise_error }

      specify { expect { subject.enum = :third }.to raise_error(InvalidAttributeValueError) }
      specify { expect { subject.enum = :first }.not_to raise_error }
      specify { expect { subject.enum = nil }.not_to raise_error }

      specify { expect { subject.ranking = -1 }.to raise_error(InvalidAttributeValueError) }
      specify { expect { subject.ranking = 3 }.not_to raise_error }

      specify { expect { subject.identifier = 'a' }.to raise_error(InvalidAttributeValueError) }
      specify { expect { subject.identifier = '-1' }.not_to raise_error }
      specify { expect { subject.identifier = '03' }.not_to raise_error }

      specify { expect { subject.even = 5 }.to raise_error(InvalidAttributeValueError) }
      specify { expect { subject.even = 4 }.not_to raise_error }
      specify { expect { subject.even = nil }.not_to raise_error }

    end

    describe 'inheritance' do

      subject { Bar().new(0) }

      it { should have_attributes(enum: :second) }

    end

  end

end