# frozen_string_literal: true

module ShibaFaker
  module AIProviders
    class Error < StandardError; end

    class Base
      def initialize(config)
        @config = config
      end

      def generate_fake_data(model_name, fields, count)
        raise NotImplementedError, "Subclasses must implement #generate_fake_data"
      end

      protected

      def build_prompt(model_name, fields, count)
        if @config.use_validations && @config.use_enhanced_prompt?
          build_enhanced_prompt(model_name, fields, count)
        else
          build_simple_prompt(model_name, fields, count)
        end
      end

      def build_simple_prompt(model_name, fields, count)
        field_descriptions = fields.map do |field, type|
          "#{field}: #{type}"
        end.join(", ")

        <<~PROMPT
          Generate #{count} realistic fake #{model_name.to_s.downcase} records as JSON array.
          Fields: #{field_descriptions}

          Requirements:
          - Return only valid JSON array
          - Make data realistic and diverse
          - Use appropriate data types
          - Ensure data consistency

          Example format:
          [
            {
              "name": "John Doe",
              "email": "john.doe@example.com",
              "age": 30
            }
          ]
        PROMPT
      end

      def build_enhanced_prompt(model_name, fields, count)
        db_manager = Database::Manager.new(@config)
        db_manager.generate_enhanced_prompt(model_name, fields, count)
      end

      def clean_json_boundary(json_content)
        return "" if json_content.nil?
        json_content.gsub(/```json|```/, "").strip
      end
    end
  end
end
