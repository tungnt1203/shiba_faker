# frozen_string_literal: true

require "httparty"
require "json"
require_relative "base"

module ShibaFaker
  module AIProviders
    class Gemini < Base
      include HTTParty

      def generate_fake_data(model_name, fields, count)
        prompt = build_prompt(model_name, fields, count)

        response = self.class.post(
          "https://generativelanguage.googleapis.com/v1beta/models/#{@config.model}:generateContent",
          query: { key: @config.api_key },
          headers: {
            "Content-Type" => "application/json"
          },
          body: {
            contents: [
              {
                role: "user",
                parts: [
                  { text: "You are a data generator. Return only valid JSON array without any explanation." },
                  { text: prompt }
                ]
              }
            ],
            generationConfig: {
              temperature: 0.8,
              maxOutputTokens: 2000
            }
          }.to_json
        )

        # Handle the response from Gemini API
        if response.body.nil?
          raise Error, "Invalid response from Gemini API: #{response.inspect}"
        end

        content = response.dig("candidates", 0, "content", "parts", 0, "text")

        if content.nil?
          error_message = response["error"]&.dig("message") || "No content returned from Gemini API"
          raise Error, "Gemini API error: #{error_message}"
        end

        cleaned_content = clean_json_boundary(content)
        begin
          puts cleaned_content
          JSON.parse(cleaned_content)
        rescue JSON::ParserError => e
          raise Error, "Failed to parse Gemini response as JSON: #{e.message}. Raw content: #{content[0..100]}"
        end
      rescue => e
        raise Error, "Failed to generate data with Gemini: #{e.message}"
      end
    end
  end
end
