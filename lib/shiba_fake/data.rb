# frozen_string_literal: true

module ShibaFake
  class Data
    def initialize
      @ai_client = Client.new
    end

    def fake_data_basic(model_name, count = 10)
      fields = extract_fields(model_name)
      data = generate_data_batch(model_name, fields, count)
      save_data(model_name, data)
    end

    private

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
    def save_data(model_name, data)
      model_name.transaction do
        data.each_slice(100) do |batch|
          model_name.insert_all(batch)
        end
      end
    end
  end
end
