# frozen_string_literal: true

require_relative '../3-1-autonomous_terminal/terminal_agent'
require 'json'

module Agents
  # Custom error raised when the supervisor Audit Agent decides to terminate the workflow
  class SecurityAuditInterventionError < StandardError
    attr_reader :reason, :iterations, :goal

    def initialize(msg, reason, iterations, goal)
      super(msg)
      @reason = reason
      @iterations = iterations
      @goal = goal
    end
  end

  # A supervisor agent implementing the Referee/Auditor pattern (defense-in-depth).
  # Intercepts execution after 3 interactions to perform a parallel audit check.
  class AuditorAgent < TerminalAgent
    # Overrides run_goal to introduce a Referee Audit check after exactly 3 interactions
    def run_goal(goal, &block)
      reset!
      
      @history << {
        role: 'user',
        parts: [{ text: "Your goal is: #{goal}\nPlease begin working autonomously to achieve this." }]
      }

      completed = false
      final_result = nil
      iteration = 0

      while !completed && iteration < @max_iterations
        iteration += 1
        yield({ type: :status, text: "Starting Autonomous Iteration #{iteration}/#{@max_iterations}..." }) if block_given?

        # 🛑 REFEREE AUDITOR INTERCEPTION POINT 🛑
        # After exactly 3 interactions have completed (on the start of iteration 4), invoke the supervisor Auditor LLM.
        if iteration == 4
          yield({ type: :status, text: "🔍 INITIATING INDEPENDENT REFEREE AUDIT REVIEW..." }) if block_given?
          audit_decision = audit_history!(goal)
          yield({ type: :audit_decision, text: audit_decision[:reason], terminate: audit_decision[:terminate] }) if block_given?

          if audit_decision[:terminate]
            raise SecurityAuditInterventionError.new(
              "Security Exception: Supervisor Audit Agent intervened and terminated execution on iteration #{iteration}!",
              audit_decision[:reason],
              iteration - 1,
              goal
            )
          end
        end

        # Call Gemini API
        response_text, function_call = call_llm

        if response_text && !response_text.strip.empty?
          yield({ type: :agent_thought, text: response_text }) if block_given?
        end

        if function_call
          fn_name = function_call['functionCall']['name']
          fn_args = function_call['functionCall']['args'] || {}

          @history << {
            role: 'model',
            parts: [{
              functionCall: {
                name: fn_name,
                args: fn_args
              }
            }]
          }

          if fn_name == 'execute_command'
            cmd = fn_args['command']
            execute_command(cmd) { |event| yield(event) if block_given? }
          elsif fn_name == 'signal_completion'
            success = fn_args['success']
            msg = fn_args['message']
            completed = true
            final_result = { success: success, message: msg, iterations: iteration }
            signal_completion(success, msg) { |event| yield(event) if block_given? }
          else
            handle_unknown_function(fn_name)
          end
        else
          handle_text_only_response(response_text)
        end
      end

      if !completed
        final_result = {
          success: false,
          message: "Reached the safety limit of #{@max_iterations} iterations without completion.",
          iterations: iteration
        }
        yield({ type: :failed, text: final_result[:message] }) if block_given?
      end

      final_result
    end

    private

    # Invoke a parallel Supervisor LLM to audit the agent's history and detect loops or violations
    #
    # @param goal [String] The original goal of the agent.
    # @return [Hash] Parsed JSON decision containing :terminate and :reason.
    def audit_history!(goal)
      formatted_history = ""
      @history.each_with_index do |turn, idx|
        role = turn[:role] == 'user' ? 'User/System' : 'Agent'
        parts_text = turn[:parts].map { |p| p[:text] || p['text'] || p.to_json }.join(" ")
        formatted_history += "[Turn #{idx + 1}] #{role}: #{parts_text}\n"
      end

      auditor_prompt = <<~PROMPT
        You are a Security Audit Supervisor LLM. Your task is to analyze the execution history of an autonomous terminal agent.
        
        Original User Goal: "#{goal}"
        
        Recent chat history of thoughts, commands, and outputs:
        #{formatted_history}
        
        Critically review if the agent is stuck in an infinite retry loop, doing redundant actions, or exhibiting compromised behavior.
        
        You MUST respond in clean JSON format with EXACTLY the following structure:
        {
          "terminate": true or false,
          "reason": "A brief explanation of why you decided to terminate or allow the agent to continue."
        }
      PROMPT

      # We call Gemini API with no tools for a pure text JSON reasoning response
      raw_response = @gemini_client.generate_content(
        "Return ONLY a valid JSON object matching the requested schema. No other text.",
        [{ role: 'user', parts: [{ text: auditor_prompt }] }]
      )

      # Clean up markdown code blocks if the model outputs ```json ... ```
      cleaned_response = raw_response.gsub(/```json|```/, '').strip
      parsed = JSON.parse(cleaned_response)

      {
        terminate: parsed['terminate'] == true,
        reason: parsed['reason'] || "No explanation provided by supervisor agent."
      }
    rescue StandardError => e
      # In case of parsing or API issues, fail safe by terminating the agent
      {
        terminate: true,
        reason: "Failed to perform supervisor audit safely: #{e.message}. Halting execution."
      }
    end
  end
end
