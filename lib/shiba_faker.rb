# frozen_string_literal: true

require_relative "shiba_faker/version"

module ShibaFaker
  class Error < StandardError; end
end

require_relative "shiba_faker/configuration"
require_relative "shiba_faker/ai_providers"
require_relative "shiba_faker/database"
require_relative "shiba_faker/generators"
require_relative "shiba_faker/client"
require_relative "shiba_faker/data"

module ShibaFaker

  class << self
    # Returns the global configuration object
    # @return [ShibaFaker::Configuration::Configuration]
    def configuration
      @configuration ||= Configuration::Configuration.new
    end

    # Configure ShibaFaker with a block
    # @yield [config] Configuration object to modify
    def configure
      yield(configuration)
    end
  end
end
