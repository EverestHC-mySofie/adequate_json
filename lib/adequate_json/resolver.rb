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
      elsif cached = serializer_cache.get(model)
        cached
      else
        serializer_id = (model.respond_to?(:serializer) && model.serializer) || model.model_name
        serializer_cache.set(model, resolve_serializer(serializer_id).new(model, @json, **args))
      end
    end

    def serializer_cache
      Cache
    end

    class Cache
      class << self
        def get(model)
          store[model.class.name]
        end

        def set(model, serializer)
          store[model.class.name] = serializer
        end

        def store
          @store ||= {}
        end
      end
    end
  end
end
