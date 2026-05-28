# frozen_string_literal: true

require_relative '../3-1-autonomous_terminal/terminal_agent'

module Agents
  # Custom error raised when the agent breaches its recursion limit
  class RecursionDepthLimitError < StandardError
    attr_reader :iterations, :goal

    def initialize(msg, iterations, goal)
      super(msg)
      @iterations = iterations
      @goal = goal
    end
  end

  # A looping agent designed to showcase turn-limit mitigation defenses.
  # If the agent exceeds its pre-configured maximum iteration limit, it raises
  # a RecursionDepthLimitError instead of silently returning success=false.
  class LoopingAgent < TerminalAgent
    # Overrides run_goal to raise a structured exception on safety cap breach
    def run_goal(goal, &block)
      result = super(goal, &block)
      
      if result && !result[:success] && result[:message].include?("Reached the safety limit")
        raise RecursionDepthLimitError.new(
          "Safety Exception: Agent breached the maximum pre-configured execution limit of #{@max_iterations} turns! Intercepting potential Financial DoS loop.",
          result[:iterations],
          goal
        )
      end

      result
    end

    private

    # Override call_llm to exclude SIGNAL_COMPLETION and implement transient error retries
    def call_llm
      attempts = 3
      delay = 2
      tries = 0
      begin
        tries += 1
        @gemini_client.generate_content(
          SYSTEM_PROMPT,
          @history,
          tools: [{ functionDeclarations: [EXECUTE_COMMAND] }]
        )
      rescue StandardError => e
        if tries < attempts && (e.message.include?("503") || e.message.include?("high demand") || e.message.include?("429"))
          puts "  ⚠️ [Gemini API 503/429] Retrying call #{tries}/#{attempts - 1}...".colorize(:yellow)
          sleep delay
          retry
        end
        raise
      end
    end
  end
end
