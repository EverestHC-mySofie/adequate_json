# frozen_string_literal: true

require 'bundler/setup'
require 'jbuilder'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

module Rails
  class Railtie
    def self.config
      @config ||= Config.new
    end

    class Config
      def after_initialize(&block)
        block.call
      end
    end
  end
end

module ActionController
  class API
    # Empty class for including modules in tests
  end
end

require 'adequate_json'
