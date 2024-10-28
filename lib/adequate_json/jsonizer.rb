# frozen_string_literal: true

module AdequateJson
  module Jsonizer
    def to_json(*_args)
      to_builder.target!
    end
  end
end
