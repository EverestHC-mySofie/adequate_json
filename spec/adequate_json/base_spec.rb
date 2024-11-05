# frozen_string_literal: true

require 'spec_helper'

RSpec.describe AdequateJson::Base do
  let(:model) { double('User', name: 'John Doe') }
  let(:json) { nil }
  let(:variant) { :default }
  let(:instance) { described_class.new(model, json, variant: variant) }

  before do
    described_class.builder(:default) do |json, model, _variant|
      json.name model.name
    end
  end

  describe '#to_builder' do
    context 'with a valid variant' do
      it 'yields the builder' do
        expect(instance).to receive(:yield_builder).and_call_original
        instance.to_builder { |json| }
      end
    end

    context 'with an unknown variant' do
      let(:variant) { :unknown }

      it 'raises an error' do
        expect do
          instance.to_builder do |json|
          end
        end.to raise_error('Unknown serializer variant unknown for AdequateJson::Base')
      end
    end
  end

  describe '#yield_builder' do
    context 'when json is nil' do
      it 'initializes a new Jbuilder and yields to it' do
        expect(Jbuilder).to receive(:new).and_yield(double('JsonBuilder').as_null_object)
        instance.send(:yield_builder, instance.class.builders[:default])
      end
    end

    context 'when json is present' do
      let(:json) { double('Json', name: '') }

      it 'executes the builder with the existing json' do
        instance = described_class.new(model, json, variant: variant)
        expect(instance).to receive(:instance_exec).with(json, model, variant, &instance.class.builders[variant])
        instance.send(:yield_builder, instance.class.builders[:default])
      end
    end
  end

  describe '#serialize' do
    context 'when model is nil' do
      it 'returns nil' do
        expect(instance.send(:serialize, nil)).to be_nil
      end
    end

    context 'when model is present' do
      it 'calls choose_serializer and returns its builder' do
        allow(instance).to receive(:choose_serializer).with(model).and_return(
          instance_double('SomeSerializer', to_builder: 'some_output')
        )
        expect(instance.send(:serialize, model)).to eq('some_output')
      end
    end
  end

  describe '.builder' do
    it 'adds a builder for a variant' do
      expect(described_class.builders[:default]).to be_present
    end
  end

  describe '#choose_serializer' do
    before do
      AdequateJson::Resolver::Cache.reset
    end

    context 'when model responds to to_hash' do
      let(:model) { double('model', to_hash: { foo: 'bar' }) }

      it 'returns an instance of AdequateJson::Hash' do
        expect(instance.choose_serializer(model)).to be_an_instance_of AdequateJson::Hash
      end
    end

    context 'when model responds to each' do
      let(:model) { double('model', each: true) }

      it 'returns an instance of AdequateJson::Collection' do
        expect(instance.choose_serializer(model)).to be_an_instance_of AdequateJson::Collection
      end
    end

    context 'when model does not have a custom serializer method' do
      let(:model) { double('model', model_name: :user) }

      it 'uses the model_name to determine the serializer' do
        serializer_class = class_double('Serializers::User').as_stubbed_const
        serializer_instance = instance_double(serializer_class)
        allow(serializer_class).to receive(:new).with(model, json).and_return(serializer_instance)

        expect(instance.choose_serializer(model)).to eq(serializer_instance)
      end
    end

    context 'when model has a custom serializer method' do
      let(:model) { double('model', serializer: :custom_serializer) }

      it 'uses the custom serializer' do
        serializer_class = class_double('Serializers::CustomSerializer').as_stubbed_const
        serializer_instance = instance_double(serializer_class)
        allow(serializer_class).to receive(:new).and_return(serializer_instance)

        expect(instance.choose_serializer(model)).to eq serializer_instance
      end
    end
  end

  describe '#assets' do
    # it 'returns Rails.application.assets when it is present' do
    #   assets = double('assets')
    #   allow(Rails.application).to receive(:assets).and_return(assets)
    #   expect(instance.assets).to eq(assets)
    # end
  end
end
