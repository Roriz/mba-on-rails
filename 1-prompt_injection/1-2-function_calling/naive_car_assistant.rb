# frozen_string_literal: true

require_relative '../../lib/gemini_api_client'

module Chatbots
  # Car inventory assistant utilizing the static tool response pattern.
  class NaiveCarAssistant
    SYSTEM_PROMPT = 'You are Watsonville Chevrolet\'s car inventory assistant. Your job is to help users query the available inventory.' \
      'When asked about the price or details of a vehicle, you MUST trigger the get_car_price tool call.'

    CONTEXT = <<~CONTEXT
      Available inventory:
      - Brand new 2026 Chevrolet Tahoe. In Stock.
    CONTEXT

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

      response_text, function_call = @gemini_client.generate_content(
        "#{SYSTEM_PROMPT}\n\nCONTEXT:\n#{CONTEXT}",
        @user_prompts,
        tools: [{ functionDeclarations: [GET_CAR_PRICE] }]
      )

      # If the model triggered a function call, execute it and return the static hardcoded message
      if function_call
        car_info = resolve_function_call(function_call)

        response_text = if car_info['error']
                          "Error: #{car_info['error']}"
                        else
                          "The #{car_info['model']} is currently #{car_info['status']} and has a starting MSRP of #{car_info['price']}."
                        end
      end

      @user_prompts << { role: 'model', parts: [{ text: response_text }] }
      response_text
    rescue StandardError => e
      "Error: #{e.message}"
    end

    private

    # Resolve local tool call execution and print developer logs.
    #
    # @param function_call_part [Hash] Function call part from Gemini candidate.
    # @return [Hash] Tool execution result containing the real price.
    def resolve_function_call(function_call_part)
      function_name = function_call_part['functionCall']['name']
      function_args = function_call_part['functionCall']['args'] || {}

      puts "\n" + "─" * 60
      puts " Executing Local Tool Call ".colorize(:yellow).swap
      puts "  ▶ Tool Name : #{function_name.to_s.colorize(:light_yellow).bold}"
      puts "  ▶ Args      : #{function_args.to_json}"

      tool_result = if function_name == 'get_car_price'
                      get_car_price(function_args['model'])
                    else # function hallucination
                      { 'error' => "Function '#{function_name}' is not supported." }
                    end

      puts "  ▶ Result    : #{tool_result.to_json.colorize(:white)}"
      puts "  ▶ Next Step : Constructing static response directly on host side."
      puts "─" * 60 + "\n"

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
