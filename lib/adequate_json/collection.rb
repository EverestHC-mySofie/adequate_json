# frozen_string_literal: true

require 'adequate_json/base'
module AdequateJson
  class Collection < AdequateJson::Base
    def initialize(collection, json = nil, variant: nil, variants: {})
      @first_level = true if json.nil?
      super
      @variant ||= :no_wrapper
    end

    def to_builder
      with_jbuilder do |json|
        json.set!(collection_key) do
          json.array! @model do |item|
            serialize item, variant: @variant, variants: @variants
          end
        end
        attach_pagination(json)
      end
    end

    private

    def collection_key
      return @model.model_name.plural if !@first_level || AdequateJson.configuration.use_model_name_for_collection_key

      AdequateJson.configuration.collection_key
    end

    def attach_pagination(json)
      return unless @first_level && @model.respond_to?(:current_page)

      json.pagination do
        json.current_page @model.current_page
        json.total_count @model.total_count
        json.next_page @model.next_page
        json.previous_page @model.prev_page
        json.total_pages @model.total_pages
      end
    end

    def with_jbuilder
      yield @json if @json
      Jbuilder.new do |json|
        @json = json
        yield json
      end
    end
  end
end
