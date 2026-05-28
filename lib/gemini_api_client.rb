# frozen_string_literal: true

require 'net/http'
require 'uri'
require 'json'

# Unified Gemini API Client for all modules.
# Supports both standard chat/text completion and function calling tools.
class GeminiApiClient
  API_URL = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-lite:generateContent'

  # Initialize the client with an API Key.
  #
  # @param api_key [String] Google Gemini API Key.
  #
  # Usage Example:
  #   client = GeminiApiClient.new(api_key: 'AIzaSy...')
  def initialize(api_key: nil)
    @api_key = api_key || ENV['GEMINI_API_KEY']
    return if @api_key

    raise 'API Key missing! Please set GEMINI_API_KEY in your environment or .env file.'
  end

  # Perform a REST API POST request to generate content.
  #
  # @param system_prompts [Array<Hash>, String] Compiled system instructions.
  # @param user_prompt [Array<Hash>] History of user prompts and model replies.
  # @param tools [Array<Hash>, nil] Optional function declaration tools.
  # @return [String, Array(String, Hash)] Parsed text response (and optional function call if tools are present).
  #
  # Usage Example:
  #   client.generate_content("Be a poet.", [{ role: 'user', parts: [{ text: 'Hello' }] }])
  def generate_content(system_prompts, user_prompt, tools: nil)
    uri = URI("#{API_URL}?key=#{@api_key}")
    request = Net::HTTP::Post.new(uri)
    request['Content-Type'] = 'application/json'
    request['Accept'] = 'application/json'

    system_parts = if system_prompts.is_a?(Array)
                     system_prompts.map { |p| { text: p.to_s } }
                   else
                     [{ text: system_prompts.to_s }]
                   end

    body = {
      contents: user_prompt,
      systemInstruction: { parts: system_parts }
    }
    body[:tools] = tools if tools

    # Print Verbose Developer Request Logs
    puts "\n" + "─" * 60
    puts " Gemini API Request Initiated ".colorize(:cyan).swap
    puts "  ▶ System Instruction(s) :"
    system_parts.each_with_index do |part, idx|
      puts "    * [Part #{idx + 1}]: #{part[:text].to_s[..50].colorize(:white)}"
    end
    puts "  ▶ Chat History Payload : #{user_prompt.size} turns"
    if tools
      puts "  ▶ Registered Tool schemas :"
      tools.each do |tool|
        tool[:functionDeclarations]&.each do |fn|
          puts "    * Function '#{fn[:name].to_s.colorize(:light_yellow)}'"
        end
      end
    end
    puts "─" * 60

    request.body = body.to_json

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(request)
    end

    unless response.is_a?(Net::HTTPSuccess)
      raise "API Request failed: #{response.code} (expected 200 OK) - #{response.body}"
    end

    parts = JSON.parse(response.body).dig('candidates', 0).dig('content')&.dig('parts') || []
    text_response = parts.map { |p| p['text'] }.compact.join("\n")

    # Print Verbose Developer Response Logs
    puts " Gemini API Response Received ".colorize(:magenta).swap
    if tools
      function_call = parts.find { |p| p.key?('functionCall') }
      if function_call
        fn_name = function_call['functionCall']['name']
        fn_args = function_call['functionCall']['args']
        puts "  ▶ 🔔 [FUNCTION CALL DETECTED] :"
        puts "    * Function   : #{fn_name.to_s.colorize(:light_yellow).bold}"
        puts "    * Parameters : #{fn_args.to_json.colorize(:white)}"
      else
        puts "  ▶ [No Function Call Triggered]"
      end
    end
    puts "─" * 60 + "\n"

    return text_response unless tools

    function_call = parts.find { |p| p.key?('functionCall') }
    [text_response, function_call]
  end
end
