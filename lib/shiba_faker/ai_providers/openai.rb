# frozen_string_literal: true

require "httparty"
require "json"
require_relative "base"

module ShibaFaker
  module AIProviders
    class OpenAI < Base
      include HTTParty

      def generate_fake_data(model_name, fields, count)
        prompt = build_prompt(model_name, fields, count)

        response = self.class.post(
          "https://api.openai.com/v1/chat/completions",
          headers: {
            "Authorization" => "Bearer #{@config.api_key}",
            "Content-Type" => "application/json"
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

        if response.nil? || !response.parsed_response.is_a?(Hash)
          raise Error, "Invalid response from OpenAI API: #{response.inspect}"
        end

        if response.parsed_response["error"]
          error_message = response.parsed_response.dig("error", "message") || "Unknown OpenAI API error"
          raise Error, "OpenAI API error: #{error_message}"
        end

        content = response.parsed_response.dig("choices", 0, "message", "content")

        if content.nil?
          raise Error, "No content returned from OpenAI API"
        end

        cleaned_content = clean_json_boundary(content)
        begin
          JSON.parse(cleaned_content)
        rescue JSON::ParserError => e
          raise Error, "Failed to parse OpenAI response as JSON: #{e.message}. Raw content: #{content[0..100]}"
        end
      rescue => e
        raise Error, "Failed to generate data with OpenAI: #{e.message}"
      end
    end
  end
end
