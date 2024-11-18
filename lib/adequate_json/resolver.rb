# frozen_string_literal: true

require 'active_support/core_ext/string/inflections'

module AdequateJson
  module Resolver
    def choose_serializer(model, **args)
      if model.respond_to?(:to_hash)
        AdequateJson::Hash.new(model.to_hash, @json, **args)
      elsif model.respond_to?(:each)
        AdequateJson::Collection.new(model, @json, **args)
      else
        model_serializer(model, **args)
      end
    end

    private

    def model_serializer(model, **args)
      serializer_id = (model.respond_to?(:serializer) && model.serializer) || model.model_name.name
      klazz = serializer_cache.get(serializer_id) ||
              serializer_cache.set(serializer_id, resolve_serializer(serializer_id))
      klazz.new(model, @json, **args)
    end

    def resolve_serializer(symbol)
      klazz = symbol.to_s.camelcase
      return serializers_module.const_get(klazz, false) if serializers_module.const_defined?(klazz, false)

      raise "Unable to find serializer for #{klazz}"
    end

    def serializers_module
      AdequateJson.configuration.serializers_module_const
    end

    def serializer_cache
      Cache
    end

    class Cache
      class << self
        def get(serializer_id)
          store[serializer_id]
        end

        def set(serializer_id, serializer)
          store[serializer_id] = serializer
          serializer
        end

        def store
          @store ||= {}
        end

        def reset!
          @store = {}
        end
      end
    end
  end
end
