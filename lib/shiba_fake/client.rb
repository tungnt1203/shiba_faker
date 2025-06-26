# frozen_string_literal: true

require 'httparty'
require 'json'

module ShibaFake
  class Client
    include HTTParty
    def initialize
      @config = ShibaFake.configuration
    end

    def fake_data(model_name, fields, count = 1)
      case @config.ai_provider
      when :openai
        generate_with_openai(model_name, fields, count)
      end
    end

    private

    def generate_with_openai(model_name, fields, count)
      prompt = build_prompt(model_name, fields, count)

      response = self.class.post(
        'https://api.openai.com/v1/chat/completions',
        headers: {
          'Authorization' => "Bearer #{@config.api_key}",
          'Content-Type' => 'application/json'
        },
        body: {
          model: @config.model,
          messages: [
            {
              role: "system",
              content: "You are a data generator. Return only valid JSON array without any explanation."
            },
            {
              role: "user",
              content: prompt
            }
          ],
          temperature: 0.8,
          max_tokens: 2000
        }.to_json
      )

      content = response.parsed_response.dig('choices', 0, 'message', 'content')
      JSON.parse(content)

    end

    def build_prompt(model_name, fields, count)
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
  end
end