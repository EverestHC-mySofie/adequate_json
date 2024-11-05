# frozen_string_literal: true

require 'spec_helper'
require 'attr_extras'

class Person
  vattr_initialize :first_name, :last_name

  def model_name
    'Person'
  end
end

module Serializers
  class Person < AdequateJson::Base
    builder :no_wrapper do |json, person|
      json.(person, :first_name, :last_name)
    end
  end
end

class Integration
  include AdequateJson::Serializer

  def render(json:)
    json.to_json
  end
end

RSpec.describe Integration do
  it 'serializes a collection of hashes containing models' do
    data = [
      { model: Person.new('Jane', 'Doe') },
      { model: Person.new('John', 'Doe') }
    ]

    json = JSON.parse(Integration.new.render_json(data))
    expect(json['collection'].first['model']['first_name']).to eq 'Jane'
    expect(json['collection'].last['model']['first_name']).to eq 'John'
  end
end
