# frozen_string_literal: true

require 'rails'

module AdequateJson
  class Railtie < ::Rails::Railtie
    config.after_initialize do
      require 'adequate_json/serializer'
      ActionController::API.include AdequateJson::Serializer
    end
  end
end
