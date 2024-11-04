# frozen_string_literal: true

module Rails
  class Railtie
    def self.config
      @config ||= Config.new
    end

    class Config
      def after_initialize(&block)
        block.call
      end
    end
  end
end

module ActionController
  class API
    # Empty class for including modules in tests
  end
end

require 'adequate_json/resolver'
require 'adequate_json/asset_helper'
require 'adequate_json/jsonizer'
require 'adequate_json/railtie'

RSpec.describe AdequateJson::Railtie do
  it 'includes AdequateJson::Serializer in ActionController::API' do
    expect(ActionController::API.included_modules).to include(AdequateJson::Serializer)
  end
end
