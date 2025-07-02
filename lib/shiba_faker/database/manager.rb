# frozen_string_literal: true

require_relative "../schema"

module ShibaFaker
  module Database
    class Manager
      def initialize(config = ShibaFaker.configuration)
        @config = config
      end

      def extract_fields(model_name)
        if @config.use_validations
          extract_fields_with_constraints(model_name)
        else
          columns = model_name.columns.reject { |c| c.name.in?(%w[id created_at updated_at]) }
          columns.map { |c| [c.name, c.type] }.to_h
        end
      end

      def extract_fields_with_constraints(model_name)
        analyzer = Schema::Analyzer.new(model_name)
        schema = analyzer.analyze

        # Convert the detailed schema back to a simple fields hash for backward compatibility
        fields = {}
        schema[:fields].each do |field_name, field_info|
          fields[field_name] = field_info[:type]
        end

        # Add enum information
        schema[:enums].each do |enum_name, values|
          fields["#{enum_name}_enum_values"] = values if fields.key?(enum_name)
        end

        # Add validation information
        schema[:validations].each do |field_name, validations|
          next unless fields.key?(field_name)

          validation_info = []
          validations.each do |validation|
            validation_info << { type: validation[:type], options: validation[:options] }
          end

          fields["#{field_name}_validations"] = validation_info if validation_info.any?
        end

        fields
      end

      def detect_foreign_keys(model_name)
        fks = {}
        model_name.reflect_on_all_associations(:belongs_to).each do |association|
          fk = association.foreign_key
          related_model = association.klass
          next unless related_model.exists?

          fks[fk] = {
            model: related_model,
            association_name: association.name
          }
        end
        fks
      end

      def load_relation_data(foreign_keys)
        relation_data = {}
        foreign_keys.each do |fk_column, association|
          related_model = association[:model]
          ids = related_model.limit(1000).pluck(related_model.primary_key.to_sym)
          relation_data[fk_column] = ids
        end
        relation_data
      end

      def save_data(model_name, data)
        model_name.transaction do
          data.each_slice(100) do |batch|
            batch.each do |attrs|
              record = model_name.new
              permitted = attrs.slice(*model_name.column_names)
              record.assign_attributes(permitted)
              record.save!
            end
          end
        end
      end

      # Get a complete analysis of the model schema including validations and constraints
      # @param model_name [Class] ActiveRecord model class
      # @return [Hash] Complete schema information
      def analyze_model_schema(model_name)
        analyzer = Schema::Analyzer.new(model_name)
        analyzer.analyze
      end

      # Generate a detailed prompt that includes validation and enum information
      # @param model_name [Class] ActiveRecord model class
      # @param fields [Hash] Field definitions
      # @param count [Integer] Number of records to generate
      # @return [String] Enhanced prompt for the AI
      def generate_enhanced_prompt(model_name, fields, count)
        schema = analyze_model_schema(model_name)

        field_descriptions = []

        # Process each field with its constraints
        fields.each do |field_name, field_type|
          description = "#{field_name}: #{field_type}"

          # Add enum information if available
          if schema[:enums].key?(field_name)
            enum_values = schema[:enums][field_name].join(", ")
            description += " (must be one of: #{enum_values})"
          end

          # Add validation information if available
          if schema[:validations].key?(field_name)
            validations = schema[:validations][field_name]
            validation_descriptions = []

            validations.each do |validation|
              case validation[:type]
              when "presence"
                validation_descriptions << "required"
              when "length"
                if validation[:options][:minimum] && validation[:options][:maximum]
                  validation_descriptions << "length between #{validation[:options][:minimum]} and #{validation[:options][:maximum]} characters"
                elsif validation[:options][:minimum]
                  validation_descriptions << "minimum length #{validation[:options][:minimum]} characters"
                elsif validation[:options][:maximum]
                  validation_descriptions << "maximum length #{validation[:options][:maximum]} characters"
                elsif validation[:options][:is]
                  validation_descriptions << "exactly #{validation[:options][:is]} characters"
                end
              when "numericality"
                opts = validation[:options]
                if opts[:greater_than]
                  validation_descriptions << "greater than #{opts[:greater_than]}"
                elsif opts[:greater_than_or_equal_to]
                  validation_descriptions << "greater than or equal to #{opts[:greater_than_or_equal_to]}"
                end

                if opts[:less_than]
                  validation_descriptions << "less than #{opts[:less_than]}"
                elsif opts[:less_than_or_equal_to]
                  validation_descriptions << "less than or equal to #{opts[:less_than_or_equal_to]}"
                end

                if opts[:only_integer]
                  validation_descriptions << "integer only"
                end
              when "inclusion"
                if validation[:options][:in].is_a?(Array)
                  values = validation[:options][:in].join(", ")
                  validation_descriptions << "must be one of: #{values}"
                end
              when "format"
                if validation[:options][:with]
                  validation_descriptions << "must match format: #{validation[:options][:with].inspect}"
                end
              end
            end

            if validation_descriptions.any?
              description += " (#{validation_descriptions.join(", ")})"
            end
          end

          field_descriptions << description
        end
        <<~PROMPT
          Generate #{count} realistic fake #{model_name.to_s.downcase} records as JSON array.
          Fields with constraints:
          #{field_descriptions.join("\n")}

          Requirements:
          - Return only valid JSON array
          - Make data realistic and diverse
          - Use appropriate data types
          - IMPORTANT: Ensure ALL constraints are respected for each field
          - Generate values that would pass validation in a real application

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
    end
  end
end
