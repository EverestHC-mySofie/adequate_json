# frozen_string_literal: true

module AdequateJson
  class Hash
    include Resolver
    include Jsonizer

    def initialize(hash, json = nil, variants: {}, **)
      @hash = hash
      @json = json
      @variants = variants
    end

    def to_builder
      if @json.nil?
        Jbuilder.new do |json|
          @json = json
          serialize_hash
        end
      else
        serialize_hash
      end
    end

    private

    def serialize_hash
      @hash.each do |key, value|
        if value.respond_to?(:to_i) || value.frozen?
          @json.set!(key, value)
        else
          @json.set!(key) do
            choose_serializer(value, variant: @variants[key] || :no_wrapper).to_builder
          end
        end
      end
    end
  end
end
