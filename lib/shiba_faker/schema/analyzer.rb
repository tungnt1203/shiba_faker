# frozen_string_literal: true

module ShibaFaker
  module Schema
    # The Analyzer class is responsible for extracting detailed schema information
    # from ActiveRecord models, including validations, enums, and other constraints.
    class Analyzer
      attr_reader :model_class

      def initialize(model_class)
        @model_class = model_class
      end

      # Analyzes the model and returns a complete schema with constraints
      # @return [Hash] Complete schema information with fields and constraints
      def analyze
        {
          table_name: model_class.table_name,
          fields: extract_fields_with_constraints,
          enums: extract_enums,
          validations: extract_validations,
          associations: extract_associations,
          constraints: extract_database_constraints
        }
      end

      # Extracts basic field information enhanced with constraints
      # @return [Hash] Field definitions with type information and constraints
      def extract_fields_with_constraints
        fields = {}

        model_class.columns_hash.each do |column_name, column|
          next if column_name == "id" || column_name.end_with?("_id") ||
                 column_name.in?(["created_at", "updated_at"])

          fields[column_name] = {
            type: column.type,
            sql_type: column.sql_type,
            null: column.null,
            default: column.default,
            limit: column.limit,
            precision: column.precision,
            scale: column.scale
          }

          # Add information about primary key
          fields[column_name][:primary_key] = true if column_name == model_class.primary_key
        end

        fields
      end

      # Extracts enum definitions from the model
      # @return [Hash] Enum definitions with allowed values
      def extract_enums
        return {} unless model_class.respond_to?(:defined_enums)

        enums = {}
        model_class.defined_enums.each do |enum_name, enum_values|
          enums[enum_name] = enum_values.keys
        end

        enums
      end

      # Extracts validation rules from the model
      # @return [Hash] Validation rules organized by field
      def extract_validations
        return {} unless model_class.respond_to?(:validators)

        validations = {}

        model_class.validators.each do |validator|
          attributes = validator.attributes
          validator_type = validator.class.name.demodulize.underscore.sub(/_validator$/, '')

          options = extract_validator_options(validator)

          attributes.each do |attribute|
            validations[attribute.to_s] ||= []
            validations[attribute.to_s] << {
              type: validator_type,
              options: options
            }
          end
        end

        validations
      end

      # Extracts associations from the model
      # @return [Hash] Association definitions
      def extract_associations
        associations = {}

        if model_class.respond_to?(:reflect_on_all_associations)
          model_class.reflect_on_all_associations.each do |association|
            associations[association.name.to_s] = {
              type: association.macro,
              class_name: association.class_name,
              foreign_key: association.foreign_key,
              options: extract_association_options(association)
            }
          end
        end

        associations
      end

      # Extracts database constraints (unique indexes, foreign keys, etc.)
      # @return [Hash] Database constraint definitions
      def extract_database_constraints
        constraints = {}

        # This requires database connection
        begin
          # Extract unique indexes
          if model_class.connection.respond_to?(:indexes)
            indexes = model_class.connection.indexes(model_class.table_name)

            indexes.each do |index|
              if index.unique
                constraints[:unique_indexes] ||= []
                constraints[:unique_indexes] << {
                  name: index.name,
                  columns: index.columns
                }
              end
            end
          end

          # Extract foreign keys if supported by the database
          if model_class.connection.respond_to?(:foreign_keys)
            foreign_keys = model_class.connection.foreign_keys(model_class.table_name)

            if foreign_keys.any?
              constraints[:foreign_keys] = foreign_keys.map do |fk|
                {
                  from_table: fk.from_table,
                  to_table: fk.to_table,
                  column: fk.column,
                  primary_key: fk.primary_key
                }
              end
            end
          end
        rescue => e
          # If we can't connect to the database, just return empty constraints
          # This allows the analyzer to work in environments without a database
          # connection, like in a gem development environment
        end

        constraints
      end

      private

      # Extracts options from a validator
      def extract_validator_options(validator)
        options = {}

        # Different validators have different options, try to extract common ones
        if validator.respond_to?(:options)
          options_hash = validator.options.dup

          # Handle special cases
          case validator
          when ActiveModel::Validations::LengthValidator
            %i[minimum maximum in within is].each do |option|
              options[option] = options_hash[option] if options_hash.key?(option)
            end
          when ActiveModel::Validations::NumericalityValidator
            %i[greater_than greater_than_or_equal_to equal_to
               less_than less_than_or_equal_to odd even only_integer].each do |option|
              options[option] = options_hash[option] if options_hash.key?(option)
            end
          when ActiveModel::Validations::InclusionValidator, ActiveModel::Validations::ExclusionValidator
            options[:in] = options_hash[:in] if options_hash.key?(:in)
          end

          # Common options for most validators
          %i[allow_nil allow_blank message on].each do |option|
            options[option] = options_hash[option] if options_hash.key?(option)
          end
        end

        options
      end

      # Extracts options from an association
      def extract_association_options(association)
        options = {}

        # Common association options
        %i[dependent counter_cache as through source polymorphic].each do |option|
          value = association.options[option]
          options[option] = value if value.present?
        end

        options
      end
    end
  end
end
