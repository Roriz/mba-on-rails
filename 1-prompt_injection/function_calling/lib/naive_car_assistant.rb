# frozen_string_literal: true

require_relative 'gemini_api_client'

module Chatbots
  class NaiveCarAssistant
    SYSTEM_PROMPT = <<~PROMPT
      You are Watsonville Chevrolet's car inventory assistant. Your job is to help users query the available inventory.#{'      '}

      When responding with the price of any vehicle obtained from the get_car_price tool, you MUST write the final response containing the literal string '\#{price}' in place of the actual price (for example: "The MSRP is \#{price}"). The hosting system will dynamically populate this template string with the actual price.
    PROMPT

    # Initialize the car assistant with a Gemini API Key.
    #
    # @param api_key [String] Google Gemini API Key.
    #
    # Usage Example:
    #   assistant = Chatbots::NaiveCarAssistant.new(api_key: "AIzaSy...")
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
    #
    # Usage Example:
    #   assistant.chat("Hello!")
    def chat(message)
      @user_prompts << { role: 'user', parts: [{ text: message }] }

      first_response, function_call = @gemini_client.generate_content(SYSTEM_PROMPT, @user_prompts)

      return first_response if function_call.nil?

      car_info = resolve_function_call(function_call)

      second_response, = @gemini_client.generate_content(SYSTEM_PROMPT, @user_prompts)

      second_response.gsub(price.to_s, car_info['price'])
    rescue StandardError => e
      "Error: #{e.message}"
    end

    private

    def resolve_function_call(function_call_part)
      function_name = function_call_part['functionCall']['name']
      function_args = function_call_part['functionCall']['args'] || {}

      tool_result = if function_name == 'get_car_price'
                      get_car_price(function_args['model'])
                    else # function hallucination
                      { 'error' => "Function '#{function_name}' is not supported." }
                    end

      @user_prompts << { role: 'model', parts: [function_call_part] }
      @user_prompts << { role: 'user', parts: [{
        functionResponse: {
          id: function_call_part['functionCall']['id'],
          name: function_name,
          response: tool_result
        }
      }] }

      tool_result
    end

    def get_car_price(model)
      if model.to_s.downcase.include?('tahoe')
        { 'model' => '2026 Chevrolet Tahoe', 'price' => '$70,000', 'status' => 'In Stock' }
      else
        { 'error' => "Vehicle model '#{model}' not found in Watsonville Chevrolet's inventory." }
      end
    end
  end
end
