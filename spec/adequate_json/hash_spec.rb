# frozen_string_literal: true

require 'spec_helper'

RSpec.describe AdequateJson::Hash do
  let(:simple_hash) { { key1: 1, key2: 'value2', key3: :symbol_value } }
  let(:complex_hash) { { key1: 1, key2: double('ComplexValue'), key3: double('AnotherComplexValue') } }

  subject { described_class.new(simple_hash) }

  before do
    allow(subject).to receive(:choose_serializer).and_return(double(to_builder: 'builder_result'))
  end

  describe '#to_builder' do
    it 'creates a new Jbuilder object when json is nil and serializes the hash' do
      expect(Jbuilder).to receive(:new)
      subject.to_builder
    end

    it 'uses the existing json object and serializes the hash' do
      json = Jbuilder.new
      expect(Jbuilder).to_not receive(:new)
      described_class.new(simple_hash, json).to_builder
    end
  end

  describe '#serialize_hash' do
    context 'with simple values' do
      it 'sets values directly for keys with values that respond to :to_i or are frozen' do
        result = subject.to_builder
        expect(result.attributes!).to eq('key1' => 1, 'key2' => 'value2', 'key3' => :symbol_value)
      end
    end

    context 'with complex values' do
      subject { described_class.new(complex_hash, Jbuilder.new) }

      it 'serializes complex values using choose_serializer' do
        complex_hash.each_value do |value|
          next if value.respond_to?(:to_i) || value.frozen?

          expect(subject).to receive(:choose_serializer).with(
            value,
            variant: anything
          ).and_return(double(to_builder: 'builder_result'))
        end
        subject.send(:serialize_hash)
      end
    end
  end
end
