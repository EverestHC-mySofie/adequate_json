# frozen_string_literal: true

module AdequateJson
  module AssetHelper
    def assets
      @assets ||= Rails.application.assets || ::Sprockets::Railtie.build_environment(Rails.application)
    end
  end
end
