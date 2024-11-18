# frozen_string_literal: true

module AdequateJson
  module Loader
    class << self
      def autoload_serializers(module_name)
        path = "app/#{module_name}"
        module_name.to_s.camelize.tap do |type_name|
          unless Object.const_defined?(type_name)
            m = Object.const_set(type_name, Module.new)
            # Listen for Zeitwerk code reloading and clear the serializers cache
            Rails.autoloaders.main.on_setup do
              AdequateJson::Resolver::Cache.reset!
            end
            Rails.autoloaders.main.push_dir(path, namespace: m)
          end
        end
      end
    end
  end

  if defined?(::Rails::Railtie)
    class Railtie < ::Rails::Railtie
      config.before_initialize do
        Loader.autoload_serializers AdequateJson.configuration.serializers_module
      end

      config.after_initialize do
        ActionController::API.include AdequateJson::Serializer
      end
    end
  end
end
