require_relative 'test_helper'
require_relative '../lib/ducktape/exception'

RSpec.describe Exception do

  let(:context) { {a: 1} }

  describe '#to_s' do

    example 'without message and context' do
      expect(Exception.new.to_s).to eq 'Exception'
    end

    example 'with message only' do
      expect(Exception.new('').to_s).to eq ''
      expect(Exception.new('exc_msg').to_s).to eq 'exc_msg'
    end

    example 'with only context' do
      expect(Exception.new(**context).to_s).to eq "Exception : #{context.inspect}"
    end

    example 'with empty message and context' do
      expect(Exception.new('', **context).to_s).to eq context.inspect
    end

    example 'with message and context' do
      expect(Exception.new('exc_msg', **context).to_s).to eq "exc_msg : #{context.inspect}"
    end

  end

  describe '#inspect' do

    example 'without message and context' do
      expect(Exception.new.inspect).to eq '#<Exception : Exception>'
    end

    example 'with message only' do
      expect(Exception.new('').inspect).to eq 'Exception'
      expect(Exception.new('exc_msg').inspect).to eq '#<Exception : exc_msg>'
    end

    example 'with only context' do
      expect(Exception.new(**context).inspect).to eq "#<Exception : Exception : #{context.inspect}>"
    end

    example 'with empty message and context' do
      expect(Exception.new('', **context).inspect).to eq "#<Exception : #{context.inspect}>"
    end

    example 'with message and context' do
      expect(Exception.new('exc_msg', **context).inspect).to eq "#<Exception : exc_msg : #{context.inspect}>"
    end

  end

end
