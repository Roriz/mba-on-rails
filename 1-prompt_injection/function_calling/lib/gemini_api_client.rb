# frozen_string_literal: true

require 'net/http'
require 'uri'
require 'json'

class GeminiApiClient
  API_URL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-lite:generateContent"
  GET_CAR_PRICE = {
    name: 'get_car_price',
    description: 'Get the MSRP price and availability of a specific car model.',
    parameters: {
      type: 'OBJECT',
      properties: {
        model: {
          type: 'STRING',
          description: 'The model name of the car (e.g. Chevrolet Tahoe)'
        }
      },
      required: ['model']
    }
  }.freeze

  # Initialize the client with an API Key.
  #
  # @param api_key [String] Google Gemini API Key.
  def initialize(api_key: nil)
    @api_key = api_key || ENV['GEMINI_API_KEY']
    raise "API Key missing! Please set GEMINI_API_KEY in your environment or .env file." unless @api_key
  end

  # Perform a REST API POST request to generate content.
  #
  # @param user_prompt [String] The message from the user.
  # @param system_prompt [String] Compiled system instructions.
  # @return [Array(String, Hash] Parsed JSON response.
  def generate_content(system_prompt, user_prompt)
    uri = URI("#{API_URL}?key=#{@api_key}")
    request = Net::HTTP::Post.new(uri)
    request['Content-Type'] = 'application/json'
    request['Accept'] = 'application/json'

    request.body = {
      contents: user_prompt,
      systemInstruction: { parts: [{ text: system_prompt }] },
      tools: [{ functionDeclarations: [GET_CAR_PRICE] }]
    }.to_json

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(request)
    end

    unless response.is_a?(Net::HTTPSuccess)
      raise "API Request failed: #{response.code} - #{response.body}"
    end

    parts = JSON.parse(response.body).dig('candidates', 0).dig('content')&.dig('parts') || []

    [
      parts.map { |p| p['text'] }.join("\n"),
      parts.find { |p| p.key?('functionCall') }
    ]
  end
end
