# frozen_string_literal: true

require_relative "ai_providers"

module ShibaFaker
  # Client class provides a simplified interface to the AI providers
  class Client
    # Initialize a new client
    # @param config [ShibaFaker::Configuration::Configuration] Configuration object
    def initialize(config = ShibaFaker.configuration)
      @config = config
      @provider = AIProviders::Factory.create(config)
    end

    # Generates fake data using configured AI provider
    #
    # @param model_name [Class, String] ActiveRecord model class or string name
    # @param fields [Hash] Field definitions with types
    # @param count [Integer] Number of records to generate
    # @return [Array<Hash>] Generated data as array of hashes
    def fake_data(model_name, fields, count = 1)
      begin
        @provider.generate_fake_data(model_name, fields, count)
      rescue AIProviders::Error => e
        raise ShibaFaker::Error, e.message
      end
    end
  end
end
