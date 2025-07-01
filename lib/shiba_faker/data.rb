# frozen_string_literal: true

require_relative "generators/factory"

module ShibaFaker
  class Data
    # Creates a new Data instance for generating fake data
    # @param config [ShibaFaker::Configuration::Configuration] Configuration object
    def initialize(config = ShibaFaker.configuration)
      @config = config
    end

    # Generate fake data for a model without considering relationships
    #
    # @param model_name [Class] ActiveRecord model class
    # @param count [Integer] Number of records to generate
    # @return [Array<Hash>] Generated data
    def fake(model_name, count = 10)
      generator = Generators::Factory.create(:simple, @config)
      generator.generate(model_name, count)
    end

    # Generate fake data for a model, including handling of foreign key relationships
    #
    # @param model_name [Class] ActiveRecord model class
    # @param count [Integer] Number of records to generate
    # @return [Array<Hash>] Generated data
    def fake_with_relations(model_name, count = 10)
      generator = Generators::Factory.create(:relations, @config)
      generator.generate(model_name, count)
    end
  end
end
