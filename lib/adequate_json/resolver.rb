# frozen_string_literal: true

module AdequateJson
  module Resolver
    def resolve_serializer(symbol)
      Serializers.const_get(symbol.to_s.camelcase)
    end

    def choose_serializer(model, **args)
      if model.respond_to?(:to_hash)
        Serializers::Hash.new(model.to_hash, @json, **args)
      elsif model.respond_to?(:each)
        Serializers::Collection.new(model, @json, **args)
      else
        serializer_id = (model.respond_to?(:serializer) && model.serializer) || model.model_name
        resolve_serializer(serializer_id).new(model, @json, **args)
      end
    end
  end
end
