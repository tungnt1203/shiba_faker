# frozen_string_literal: true

module ShibaFaker
  module Generators
    class BaseGenerator
      def initialize(config = ShibaFaker.configuration)
        @config = config
        @database_manager = Database::Manager.new(config)
        @ai_provider = AIProviders::Factory.create(config)
      end

      def generate(model_name, count = 10)
        raise NotImplementedError, "Subclasses must implement #generate"
      end

      protected

      def generate_data_batch(model_name, fields, count)
        @ai_provider.generate_fake_data(model_name, fields, count)
      end
    end
  end
end
