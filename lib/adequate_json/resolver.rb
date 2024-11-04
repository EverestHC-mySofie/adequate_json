# frozen_string_literal: true

require 'active_support/core_ext/string/inflections'

module AdequateJson
  module Resolver
    def resolve_serializer(symbol)
      AdequateJson.const_get(symbol.to_s.camelcase)
    end

    def choose_serializer(model, **args)
      if model.respond_to?(:to_hash)
        AdequateJson::Hash.new(model.to_hash, @json, **args)
      elsif model.respond_to?(:each)
        AdequateJson::Collection.new(model, @json, **args)
      else
        serializer_id = (model.respond_to?(:serializer) && model.serializer) || model.model_name
        resolve_serializer(serializer_id).new(model, @json, **args)
      end
    end
  end
end
