# frozen_string_literal: true

module ShibaFaker
  module Configuration
    class Configuration
      attr_accessor :ai_provider, :api_key, :model, :database_config, :default_locale, :use_validations, :prompt_style

      def initialize
        @ai_provider = :openai
        @model = "gpt-3.5-turbo"
        @default_locale = :en
        @database_config = {}
        @use_validations = true
        @prompt_style = :enhanced
      end

      def openai?
        @ai_provider == :openai
      end

      def gemini?
        @ai_provider == :gemini
      end

      def use_enhanced_prompt?
        @prompt_style == :enhanced
      end
    end
  end
end
