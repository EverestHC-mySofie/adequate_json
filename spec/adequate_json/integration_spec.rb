# frozen_string_literal: true

require 'spec_helper'
require 'attr_extras'

class Person
  vattr_initialize :first_name, :last_name, :address

  def model_name
    Struct.new(:name).new('Person')
  end

  def errors
    Struct.new(:messages).new({ first_name: "can't be blank" })
  end
end

class Address
  vattr_initialize :number, :street_name

  def model_name
    'Address'
  end

  def errors
    Struct.new(:messages).new({ number: 'must exists' })
  end
end

module Serializers
  class Person < AdequateJson::Base
    builder do |json, person|
      json.person do
        serialize person, variant: :no_wrapper
      end
    end

    builder :no_wrapper do |json, person|
      json.call(person, :first_name, :last_name)
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
      { model: Person.new('Jane', 'Doe', Address.new('20', 'Rue des roses')) },
      { model: Person.new('John', 'Doe', Address.new('20', 'Rue des roses')) }
    ]

    json = JSON.parse(Integration.new.render_json(data))
    expect(json['collection'].first['model']['first_name']).to eq 'Jane'
    expect(json['collection'].last['model']['first_name']).to eq 'John'
  end

  it 'renders errors correctly' do
    data = Person.new('Jane', 'Doe', Address.new('20', 'Rue des roses'))
    json = JSON.parse(Integration.new.render_error(:invalid_model, data))

    expect(json['error']).not_to be_nil
    expect(json['error']['message']).not_to be_nil
    expect(json['error']['code']).to eq 'invalid_model'
  end

  it 'renders errors for included models' do
    data = Person.new('Jane', 'Doe', Address.new('20', 'Rue des roses'))
    json = JSON.parse(Integration.new.render_error(:invalid_model, data, includes: :address))

    expect(json['error']).not_to be_nil
    expect(json['error']['message']).not_to be_nil
    expect(json['error']['code']).to eq 'invalid_model'
    expect(json['error']['details']['address']['number']).to eq 'must exists'
  end
end
