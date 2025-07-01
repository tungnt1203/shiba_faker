# frozen_string_literal: true

require_relative "base_generator"
require_relative "simple_generator"
require_relative "relations_generator"

module ShibaFaker
  module Generators
    class Factory
      # Returns an appropriate generator based on the type
      #
      # @param type [Symbol] :simple or :relations
      # @param config [ShibaFaker::Configuration::Configuration] Configuration object
      # @return [ShibaFaker::Generators::BaseGenerator] A generator instance
      def self.create(type = :simple, config = ShibaFaker.configuration)
        case type
        when :simple
          SimpleGenerator.new(config)
        when :relations
          RelationsGenerator.new(config)
        else
          raise Error, "Unsupported generator type: #{type}"
        end
      end
    end
  end
end
