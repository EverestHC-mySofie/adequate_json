# frozen_string_literal: true

require 'spec_helper'

RSpec.describe AdequateJson::Collection do
  let(:item1) { double('Item', id: 1, name: 'Item 1') }
  let(:item2) { double('Item', id: 2, name: 'Item 2') }
  let(:collection) { [item1, item2] }
  let(:json) { nil }
  let(:variant) { :no_wrapper }
  let(:model_name) { 'items' }

  subject { described_class.new(collection, json, variant: variant) }

  before do
    allow(subject).to receive(:serialize) { |item| { id: item.id, name: item.name } }
  end

  describe '#initialize' do
    it 'sets @first_level to true if json is nil' do
      collection_serializer = AdequateJson::Collection.new(collection)
      expect(collection_serializer.instance_variable_get(:@first_level)).to eq(true)
    end

    it 'sets @variant to :no_wrapper by default' do
      collection_serializer = AdequateJson::Collection.new(collection)
      expect(collection_serializer.instance_variable_get(:@variant)).to eq(:no_wrapper)
    end
  end

  describe '#to_builder' do
    context 'when @first_level is true' do
      it 'wraps collection in the :collection key' do
        json_output = subject.to_builder.attributes!
        expect(json_output).to have_key('collection')
        expect(json_output['collection']).to be_an(Array)
      end
    end

    context 'when @first_level is false' do
      let(:json) { Jbuilder.new }

      it 'wraps collection in the pluralized model name key' do
        allow(collection).to receive_message_chain(:model_name, :plural).and_return(model_name)
        json_output = subject.to_builder.attributes!
        expect(json_output).to have_key(model_name)
        expect(json_output[model_name]).to be_an(Array)
      end
    end
  end

  describe '#attach_pagination' do
    context 'when collection is paginated' do
      before do
        allow(collection).to receive(:current_page).and_return(1)
        allow(collection).to receive(:total_count).and_return(10)
        allow(collection).to receive(:next_page).and_return(2)
        allow(collection).to receive(:prev_page).and_return(nil)
        allow(collection).to receive(:total_pages).and_return(5)
      end

      it 'adds pagination details to JSON output' do
        json_output = subject.to_builder.attributes!
        expect(json_output['pagination']).to eq({
                                                  'current_page' => 1,
                                                  'total_count' => 10,
                                                  'next_page' => 2,
                                                  'previous_page' => nil,
                                                  'total_pages' => 5
                                                })
      end
    end

    context 'when collection is not paginated' do
      it 'does not add pagination to JSON output' do
        json_output = subject.to_builder.attributes!
        expect(json_output).not_to have_key('pagination')
      end
    end
  end

  describe '#with_jbuilder' do
    it 'creates a new Jbuilder instance if none provided' do
      expect(subject.to_builder).to be_a(Jbuilder)
    end
  end
end
