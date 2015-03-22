require_relative 'test_helper'

include Ducktape

class X
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

RSpec.instance_eval do

  describe Bindable do

    subject { X.new(0) }

    describe 'validation' do

      it { expect { subject.name = 1 }.to raise_error(InvalidAttributeValueError) }
      it { expect { subject.name = '1' }.not_to raise_error }
      it { expect { subject.name = :one }.not_to raise_error }

      it { expect { subject.enum = :third }.to raise_error(InvalidAttributeValueError) }
      it { expect { subject.enum = :first }.not_to raise_error }
      it { expect { subject.enum = nil }.not_to raise_error }

      it { expect { subject.ranking = -1 }.to raise_error(InvalidAttributeValueError) }
      it { expect { subject.ranking = 3 }.not_to raise_error }

      it { expect { subject.identifier = 'a' }.to raise_error(InvalidAttributeValueError) }
      it { expect { subject.identifier = '-1' }.not_to raise_error }
      it { expect { subject.identifier = '03' }.not_to raise_error }

      it { expect { subject.even = 5 }.to raise_error(InvalidAttributeValueError) }
      it { expect { subject.even = 4 }.not_to raise_error }
      it { expect { subject.even = nil }.not_to raise_error }

    end

  end

end