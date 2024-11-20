# frozen_string_literal: true

module AdequateJson
  class Configuration
    attr_accessor :use_model_name_for_collection_key, :collection_key, :serializers_module, :i18n_errors_scope

    def initialize
      @use_model_name_for_collection_key = false
      @collection_key = :collection
      @serializers_module = :serializers
      @i18n_errors_scope = %i[api errors]
    end

    def serializers_module_const
      AdequateJson.configuration.serializers_module.to_s.camelcase.constantize
    end
  end

  class ConfigurationBuilder
    def initialize(configuration)
      @configuration = configuration
    end

    def method_missing(name, *args, **kwargs)
      @configuration.send("#{name}=", *args, **kwargs)
    end

    def respond_to_missing?(name, _ = false)
      false unless @configuration.respond_to?(name)
    end
  end
end
