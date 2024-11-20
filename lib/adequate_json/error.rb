# frozen_string_literal: true

module AdequateJson
  class Error < Base
    builder do |json, model, error, message, includes|
      json.error do
        json.code error
        json.message message
        if model
          json.details do
            includes_to_errors(model, includes, model.errors.messages.dup).each do |model_name, errors|
              json.set! model_name, errors
            end
          end
        end
      end
    end

    def initialize(model, error = nil, message = nil, includes = nil)
      super(model)
      @error = error
      @message = message
      @includes = includes
    end

    def includes_to_errors(model, includes, attributes = {})
      unless model.nil?
        each_inclusion(includes) do |child, value|
          submodel = model.send(child)
          subattributes = attributes[submodel.model_name.to_s.underscore] = submodel.errors.messages.dup
          includes_to_errors(submodel, value, subattributes)
        end
      end
      attributes
    end

    def each_inclusion(includes, &)
      unless includes.respond_to?(:keys)
        includes = [includes].flatten.compact.inject({}) do |hash, key|
          hash.tap do
            hash[key] = nil
          end
        end
      end
      includes.each(&)
    end

    def yield_builder(builder)
      Jbuilder.new do |json|
        instance_exec json, @model, @error, @message, @includes, &builder
      end
    end

    class << self
      def for(error, model = nil, includes = nil)
        new(model, error, I18n.t(error, scope: AdequateJson.configuration.i18n_errors_scope), includes)
      end
    end
  end
end
