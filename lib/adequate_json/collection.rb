# frozen_string_literal: true

module AdequateJson
  class Collection < AdequateJson::Base
    def initialize(collection, json = nil, variant: nil)
      @first_level = true if json.nil?
      super
      @variant ||= :no_wrapper
    end

    def to_builder
      with_jbuilder do |json|
        json.set!(@first_level ? :collection : @model.model_name.plural) do
          json.array! @model do |item|
            serialize item, variant: @variant
          end
        end
        attach_pagination(json)
      end
    end

    private

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
