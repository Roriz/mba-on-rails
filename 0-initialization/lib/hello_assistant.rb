# frozen_string_literal: true

require_relative 'gemini_api_client'

module Chatbots
  class HelloAssistant
    SYSTEM_PROMPT = <<~PROMPT
      You are a helpful, friendly assistant. Keep your responses concise.
    PROMPT

    # Initialize the Hello Assistant with a Gemini API Key.
    #
    # @param api_key [String] Google Gemini API Key.
    def initialize(api_key: nil)
      @gemini_client = GeminiApiClient.new(api_key: api_key)
      @user_prompts = []
    end

    def reset!
      @user_prompts = []
    end

    def history
      @user_prompts
    end

    # Send a message to the assistant and get a response.
    #
    # @param message [String] The message from the user.
    # @return [String] The assistant response text or error message.
    def chat(message)
      @user_prompts << { role: 'user', parts: [{ text: message }] }

      @gemini_client.generate_content(SYSTEM_PROMPT, @user_prompts)
    rescue StandardError => e
      "Error: #{e.message}"
    end
  end
end
