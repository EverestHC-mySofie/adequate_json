# frozen_string_literal: true

require 'spec_helper'

RSpec.describe AdequateJson::ConfigurationBuilder do
  it 'assigns known parameters' do
    configuration = AdequateJson::Configuration.new
    described_class.new(configuration).tap do |builder|
      %i[use_model_name_for_collection_key collection_key serializers_module].each do |m|
        builder.send m, 1
        expect(configuration.send(m)).to eq 1
      end
    end
  end
end
