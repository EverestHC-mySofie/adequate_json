# frozen_string_literal: true

module AdequateJson
  class Base
    include Resolver
    include Jsonizer

    def initialize(model, json = nil, variant: nil, variants: {})
      @model = model
      @variant = variant
      @variants = variants
      @json = json
    end

    def to_builder
      variant = @variant || :default
      builder = self.class.builders[variant]
      raise "Unknown serializer variant #{variant} for #{self.class.name}" if builder.nil?

      yield_builder builder
    end

    protected

    def yield_builder(builder)
      if @json.nil?
        Jbuilder.new do |json|
          @json = json
          instance_exec json, @model, @variant, &builder
        end
      else
        instance_exec @json, @model, @variant, &builder
      end
    end

    def serialize(model, **options)
      return if model.nil?

      choose_serializer(model, **options).to_builder
    end

    class << self
      def builder(variant = nil, &block)
        builders[variant || :default] = block
      end

      def builders
        @builders ||= {}
      end
    end
  end
end
