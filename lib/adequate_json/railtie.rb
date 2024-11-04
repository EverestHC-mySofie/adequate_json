# frozen_string_literal: true

module AdequateJson
  if defined?(::Rails::Railtie)
    class Railtie < ::Rails::Railtie
      config.after_initialize do
        require 'adequate_json/serializer'
        ActionController::API.include AdequateJson::Serializer
      end
    end
  end
end
