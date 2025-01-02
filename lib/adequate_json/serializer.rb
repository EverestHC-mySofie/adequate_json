# frozen_string_literal: true

module AdequateJson
  module Serializer
    include AdequateJson::Resolver

    def render_json(model, variant: nil, variants: {}, **options)
      render json: choose_serializer(model, variant: variant, variants: variants), **options
    end

    def render_error(error, model = nil, includes: nil, **options)
      render json: Error.for(error, model, includes), **options
    end
  end
end
