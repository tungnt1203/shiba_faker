# frozen_string_literal: true

module ShibaFaker
  module Generators
    class RelationsGenerator < BaseGenerator
      def generate(model_name, count = 10)
        foreign_keys = @database_manager.detect_foreign_keys(model_name)

        if foreign_keys.empty?
          # If no foreign keys found, fall back to simple generation
          return SimpleGenerator.new(@config).generate(model_name, count)
        end

        # Extract fields and load relation data
        fields = @database_manager.extract_fields(model_name)
        relation_data = @database_manager.load_relation_data(foreign_keys)

        # Generate data with AI, excluding foreign key fields
        ai_fields = fields.reject do |field_name, _|
          foreign_keys.key?(field_name) || foreign_keys.key?(field_name.to_sym)
        end

        # Generate the basic data without relations
        fake_data = generate_data_batch(model_name, ai_fields, count)

        # Add the foreign key values
        complete_data = add_foreign_keys(fake_data, foreign_keys, relation_data)

        # Save to database
        @database_manager.save_data(model_name, complete_data)

        complete_data
      end

      private

      def add_foreign_keys(data, foreign_keys, relation_data)
        data.map do |record|
          foreign_keys.each_key do |fk_column|
            available_ids = relation_data[fk_column]
            record[fk_column.to_s] = available_ids.sample if available_ids&.any?
          end
          record
        end
      end
    end
  end
end
