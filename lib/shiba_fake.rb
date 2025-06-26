# frozen_string_literal: true

require_relative "shiba_fake/version"
require_relative "shiba_fake/client"

module ShibaFake
  class Error < StandardError; end
  
  class << self
    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration)
    end

  end

  class Configuration
    attr_accessor :ai_provider, :api_key, :model, :database_config, :default_locale

    def initialize
      @ai_provider = :openai
      @model = "gpt-3.5-turbo"
      @default_locale = :en
      @database_config = {}
    end

    def openai?
      @ai_provider == :openai
    end
  end
end
