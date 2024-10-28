# frozen_string_literal: true
require 'rails'

module AdequateJson
  module Serializer
    include AdequateJson::Resolver

    def render_json(model, variant: nil, **)
      render json: choose_serializer(model, variant:), **
    end

    def render_error(error, model = nil, includes: nil, **)
      render json: Serializers::Error.for(error, model, includes), **
    end
  end
end