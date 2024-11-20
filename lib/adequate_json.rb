# frozen_string_literal: true

require 'jbuilder'
require 'adequate_json/resolver'
require 'adequate_json/jsonizer'
require 'adequate_json/base'
require 'adequate_json/error'
require 'adequate_json/hash'
require 'adequate_json/collection'
require 'adequate_json/configuration'
require 'adequate_json/serializer'
require 'adequate_json/version'

module AdequateJson
  class << self
    def configure
      yield ConfigurationBuilder.new(configuration)
    end

    def configuration
      @configuration ||= Configuration.new
    end
  end
end

require 'adequate_json/railtie' if defined?(::Rails::Railtie)
