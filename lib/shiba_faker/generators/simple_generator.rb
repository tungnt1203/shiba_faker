# frozen_string_literal: true

module ShibaFaker
  module Generators
    class SimpleGenerator < BaseGenerator
      def generate(model_name, count = 10)
        fields = @database_manager.extract_fields(model_name)
        data = generate_data_batch(model_name, fields, count)
        @database_manager.save_data(model_name, data)
        data
      end
    end
  end
end
