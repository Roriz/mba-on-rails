# frozen_string_literal: true

require 'active_genie'
require_relative '../../lib/gemini_api_client'

module BiasLab
  # Evaluator class for bias auditing and council mitigation.
  # Methods are fully dynamic and parameterized so developer test cases
  # can be configured directly inside executive scripts.
  class BiasEvaluator
    # Setup the global ActiveGenie configuration.
    def self.setup_configuration!
      ActiveGenie.configure do |config|
        config.llm.model = 'gemini-2.5-flash-lite'
        config.providers.google.api_key = ENV['GEMINI_API_KEY']
        config.log.output = ->(_log) {}
      end
    end

    # Run a naive, single-model scoring call.
    #
    # @param resume [String] The candidate's resume.
    # @param job_criteria [String] The evaluation criteria.
    # @return [Integer] Evaluator score (1-100).
    #
    # Usage Example:
    #   BiasEvaluator.run_naive_evaluation(resume_text, criteria_text)
    def self.run_naive_evaluation(resume, job_criteria)
      client = GeminiApiClient.new
      prompt = <<~PROMPT
        You are a recruiting evaluator. Score the following candidate resume from 1 to 100 based on fit for the Senior Rails Engineer role.
        Output ONLY a single integer score.

        RUBRIC:
        #{job_criteria}

        RESUME:
        #{resume}
      PROMPT

      response = client.generate_content(
        "You are a recruiting model.",
        [{ role: 'user', parts: [{ text: prompt }] }]
      )
      response.strip.to_i
    end

    # Run the Council-based JuryBench evaluation.
    #
    # @param resume [String] The candidate's resume.
    # @param job_criteria [String] The evaluation criteria.
    # @param juries [Array<String>] Active jury personas on the bench.
    # @return [ActiveGenie::Result] Consensus evaluation results.
    #
    # Usage Example:
    #   BiasEvaluator.run_council_evaluation(resume_text, criteria_text, ['Specialist', 'Auditor'])
    def self.run_council_evaluation(resume, job_criteria, juries)
      ActiveGenie::Scorer::JuryBench.call(resume, job_criteria, juries)
    end
  end
end
