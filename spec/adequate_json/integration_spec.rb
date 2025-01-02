# frozen_string_literal: true

require 'spec_helper'
require 'attr_extras'

class Person
  vattr_initialize :id, :first_name, :last_name, :address

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

class Device
  vattr_initialize :id, :name

  def model_name
    Struct.new(:name).new('Device')
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

    builder :anonymised do |json, person|
      json.call(person, :id)
    end
  end

  class Device < AdequateJson::Base
    builder do |json, device|
      json.device do
        serialize device, variant: :no_wrapper
      end
    end

    builder :no_wrapper do |json, device|
      json.call(device, :id, :name)
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
      { model: Person.new('id-1', 'Jane', 'Doe', Address.new('20', 'Rue des roses')) },
      { model: Person.new('id-2', 'John', 'Doe', Address.new('20', 'Rue des roses')) }
    ]

    json = JSON.parse(Integration.new.render_json(data))
    expect(json['collection'].first['model']['first_name']).to eq 'Jane'
    expect(json['collection'].last['model']['first_name']).to eq 'John'
  end

  it 'renders errors correctly' do
    data = Person.new('id-1', 'Jane', 'Doe', Address.new('20', 'Rue des roses'))
    json = JSON.parse(Integration.new.render_error(:invalid_model, data))

    expect(json['error']).not_to be_nil
    expect(json['error']['message']).not_to be_nil
    expect(json['error']['code']).to eq 'invalid_model'
  end

  it 'renders errors for included models' do
    data = Person.new('id-1', 'Jane', 'Doe', Address.new('20', 'Rue des roses'))
    json = JSON.parse(Integration.new.render_error(:invalid_model, data, includes: :address))

    expect(json['error']).not_to be_nil
    expect(json['error']['message']).not_to be_nil
    expect(json['error']['code']).to eq 'invalid_model'
    expect(json['error']['details']['address']['number']).to eq 'must exists'
  end

  it 'uses multiple variants for hashes' do
    person = Person.new('id-person', 'Jane', 'Doe', Address.new('20', 'Rue des roses'))
    device = Device.new('id-device', 'iPhone')
    hash = { person:, device: }
    json = JSON.parse(Integration.new.render_json(hash, variants: { person: :anonymised }))
    expect(json['person']['id']).to eq 'id-person'
    expect(json['person']['first_name']).to be_nil
    expect(json['person']['last_name']).to be_nil
    expect(json['device']['id']).to eq 'id-device'
    expect(json['device']['name']).to eq 'iPhone'
  end

  it 'uses multiple variants for collection of hashes' do
    person1 = Person.new('id-person1', 'Jane', 'Doe', Address.new('20', 'Rue des roses'))
    person2 = Person.new('id-person2', 'Jean', 'Doe', Address.new('20', 'Rue des roses'))
    device1 = Device.new('id-device1', 'iPhone')
    device2 = Device.new('id-device2', 'Samsung')

    data = [{ person: person1, device: device1 }, { person: person2, device: device2 }]
    json = JSON.parse(Integration.new.render_json(data, variants: { person: :anonymised }))
    expect(json['collection'][0]['person']['id']).to eq 'id-person1'
    expect(json['collection'][0]['person']['first_name']).to be_nil
    expect(json['collection'][0]['person']['last_name']).to be_nil
    expect(json['collection'][0]['device']['id']).to eq 'id-device1'
    expect(json['collection'][0]['device']['name']).to eq 'iPhone'
    expect(json['collection'][1]['person']['id']).to eq 'id-person2'
    expect(json['collection'][1]['person']['first_name']).to be_nil
    expect(json['collection'][1]['person']['last_name']).to be_nil
    expect(json['collection'][1]['device']['id']).to eq 'id-device2'
    expect(json['collection'][1]['device']['name']).to eq 'Samsung'
  end
end
