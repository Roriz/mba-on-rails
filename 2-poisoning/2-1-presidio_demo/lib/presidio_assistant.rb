# frozen_string_literal: true

require_relative '../../../lib/gemini_api_client'
require_relative 'presidio_client'

module Chatbots
  # B2B Enterprise Assistant with permanent Presidio PII Interceptor defenses.
  class PresidioAssistant
    SYSTEM_PROMPT = <<~PROMPT
      You are a friendly B2B Enterprise Assistant. Your job is to process client inquiries.
      Keep your responses extremely brief and professional.
    PROMPT

    attr_reader :diagnostic_log

    # Initialize the Presidio assistant.
    #
    # @param api_key [String] Google Gemini API Key.
    def initialize(api_key: nil)
      @gemini_client = GeminiApiClient.new(api_key: api_key)
      @presidio_client = PresidioClient.new
      @user_prompts = []
      @pii_mapping = {} # Safe local session-like mapping (never stored in a cookie)
      @diagnostic_log = []
    end

    def reset!
      @user_prompts = []
      @pii_mapping = {}
      @diagnostic_log = []
    end

    def history
      @user_prompts
    end

    # Send a message to the assistant, applying the Interceptor pattern.
    #
    # @param message [String] The message from the user.
    # @return [String] The re-hydrated assistant response text.
    def chat(message)
      @diagnostic_log = [] # Clear last turn's diagnostics

      # Safe mode: INTERCEPT
      log_diagnostic('Phase 1: Intercept', "Received raw user input:\n\"#{message}\"")

      # Call Microsoft Presidio
      res = @presidio_client.anonymize(message)

      if !res[:success]
        raise "Presidio Analysis failed: #{res[:error]}"
      end

      anonymized_text = res[:anonymized_text]
      neutralized_text = res[:neutralized_text]
      pii_items = res[:pii_items] || []
      title_changes = res[:title_changes] || []

      # Save the PII to our secure local mapping
      pii_items.each do |item|
        @pii_mapping[item[:token]] = item[:original]
      end

      # Log PII mapping
      if pii_items.any?
        mapping_details = pii_items.map { |item| "  * #{item[:token]} => \"#{item[:original]}\" (Type: #{item[:entity_type]})" }.join("\n")
        log_diagnostic('Phase 2: Map PII', "Stored unique token-to-value map server-side:\n#{mapping_details}")
      else
        log_diagnostic('Phase 2: Map PII', 'No PII entities detected.')
      end

      # Log Gender Neutralization
      if title_changes.any?
        neutralization_details = title_changes.map { |change| "  * \"#{change[:original]}\" => \"#{change[:neutralized]}\"" }.join("\n")
        log_diagnostic('Phase 3: Neutralization', "Applied Portuguese gender neutralization/stemming:\n#{neutralization_details}")
      else
        log_diagnostic('Phase 3: Neutralization', 'No gendered professional titles neutralized.')
      end

      log_diagnostic('Phase 4: Forward', "Sending anonymized and neutralized text to Gemini:\n\"#{neutralized_text}\"")

      # Forward to the model
      @user_prompts << { role: 'user', parts: [{ text: neutralized_text }] }
      raw_llm_response = @gemini_client.generate_content(SYSTEM_PROMPT, @user_prompts)

      log_diagnostic('Phase 5: Intercept Response', "Received raw response from Gemini:\n\"#{raw_llm_response}\"")

      # Re-hydrate the response by replacing tokens with original PII values
      re_hydrated_response = raw_llm_response.dup
      @pii_mapping.each do |token, original_value|
        re_hydrated_response.gsub!(token, original_value)
      end

      log_diagnostic('Phase 6: Re-hydrate', "Re-hydrated tokens using local map:\n\"#{re_hydrated_response}\"")

      # Add re-hydrated response to chat history
      @user_prompts << { role: 'model', parts: [{ text: re_hydrated_response }] }

      re_hydrated_response
    rescue StandardError => e
      "Error: #{e.message}"
    end

    private

    def log_diagnostic(phase, details)
      @diagnostic_log << { phase: phase, details: details }
    end
  end
end
