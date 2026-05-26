# frozen_string_literal: true

require 'net/http'
require 'uri'
require 'json'

class GeminiApiClient
  API_URL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-lite:generateContent"

  # Initialize the client with an API Key.
  #
  # @param api_key [String] Google Gemini API Key.
  def initialize(api_key: nil)
    @api_key = api_key || ENV['GEMINI_API_KEY']
    raise "API Key missing! Please set GEMINI_API_KEY in your environment or .env file." unless @api_key
  end

  # Perform a REST API POST request to generate content.
  #
  # @param system_prompts [Array<Hash>] Compiled system instructions.
  # @param user_prompt [Array<Hash>] History of user prompts and model replies.
  # @return [String] Parsed text response.
  def generate_content(system_prompts, user_prompt)
    uri = URI("#{API_URL}?key=#{@api_key}")
    request = Net::HTTP::Post.new(uri)
    request['Content-Type'] = 'application/json'
    request['Accept'] = 'application/json'

    request.body = {
      contents: user_prompt,
      systemInstruction: { parts: system_prompts.map { |p| { text: p } } }
    }.to_json

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(request)
    end

    unless response.is_a?(Net::HTTPSuccess)
      raise "API Request failed: #{response.code} - #{response.body}"
    end

    parts = JSON.parse(response.body).dig('candidates', 0).dig('content')&.dig('parts') || []
    parts.map { |p| p['text'] }.join("\n")
  end
end
