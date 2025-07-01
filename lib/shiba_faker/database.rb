# frozen_string_literal: true

require_relative "database/manager"
require_relative "schema"

module ShibaFaker
  module Database
    # This module provides database interaction functionality
    # The Manager class handles database operations like extracting fields,
    # detecting relationships, analyzing validations, and persisting generated data
  end
end
