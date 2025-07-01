# frozen_string_literal: true

require_relative "base"
require_relative "openai"
require_relative "gemini"

module ShibaFaker
  module AIProviders
    class Factory
      def self.create(config)
        case config.ai_provider
        when :openai
          OpenAI.new(config)
        when :gemini
          Gemini.new(config)
        else
          raise Error, "Unsupported AI provider: #{config.ai_provider}"
        end
      end
    end
  end
end
