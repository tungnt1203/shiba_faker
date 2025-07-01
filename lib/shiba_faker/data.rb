# frozen_string_literal: true

module ShibaFaker
  class Data
    def initialize
      @ai_client = Client.new
    end

    def fake(model_name, count = 10)
      fields = extract_fields(model_name)
      data = generate_data_batch(model_name, fields, count)
      save_data(model_name, data)
    end

    def fake_with_relations(model_name, count = 10)
      fks = detect_fks(model_name)
      if fks.empty?
        fake(model_name, count)
      else
        fields = extract_fields(model_name)
        relation_data = load_relation_data(fks)
        data = generate_data_with_relations(model_name, fields, count, relation_data, fks)
        save_data(model_name, data)
      end
    end

    private

    def load_relation_data(fks)
      relation_data = {}
      fks.each do |fk_column, association|
        related_model = association[:model]
        ids = related_model.limit(1000).pluck(related_model.primary_key.to_sym)
        relation_data[fk_column] = ids
        puts "Found #{ids.count} records in #{related_model.name} for #{fk_column}"
      end
      relation_data
    end

    def detect_fks(model_name)
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

    def extract_fields(model_name)
      columns = model_name.columns.reject { |c| c.name.in?(%w[id created_at updated_at]) }
      columns.map { |c| [c.name, c.type] }.to_h
    end

    def generate_data_batch(model_name, fields, count)
      all_data = []
      batch_data = @ai_client.fake_data(model_name, fields, count)
      all_data.concat(batch_data)
      all_data
    end

    def generate_data_with_relations(model_name, fields, count, relation_data, foreign_keys)
      ai_fields = fields.reject do |field_name, _|
        foreign_keys.key?(field_name) || foreign_keys.key?(field_name.to_sym)
      end

      puts "Generating AI data for fields: #{ai_fields.keys.join(", ")}"
      puts "Foreign keys will be auto-assigned: #{foreign_keys.keys.join(", ")}"

      fake_data = @ai_client.fake_data(model_name, ai_fields, count)

      fake_data.map do |record|
        foreign_keys.each_key do |fk_column|
          available_ids = relation_data[fk_column]
          record[fk_column.to_s] = available_ids.sample if available_ids.any?
        end
        record
      end
    end

    def save_data(model_name, data)
      model_name.transaction do
        data.each_slice(100) do |batch|
          model_name.insert_all(batch)
        end
      end
    end
  end
end
