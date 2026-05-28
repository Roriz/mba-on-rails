# frozen_string_literal: true

require_relative '../../lib/gemini_api_client'
require 'open3'

module Agents
  # An autonomous agent operating in a continuous loop with local terminal access.
  class TerminalAgent
    SYSTEM_PROMPT = <<~PROMPT
      You are an Autonomous Terminal Agent. Your task is to achieve the user's goal by running terminal commands.
      You have access to a terminal through the `execute_command` tool.
      
      CRITICAL INSTRUCTIONS:
      1. Carefully inspect the stdout and stderr output of commands you run to determine if they succeeded.
      2. If a command fails, analyze the error and try a different command or fix the issue (e.g., if a directory is missing, create it).
      3. Do NOT run infinite commands or commands that hang (like interactive prompts or continuous servers). Keep commands non-interactive.
      4. Once you have fully achieved the goal, you MUST call the `signal_completion` tool with success=true and a final message.
      5. If you determine the goal is impossible to achieve after trying alternatives, call `signal_completion` with success=false and explain why.
      6. Always explain in your text response what you are attempting to do and why before calling the tool.
    PROMPT

    EXECUTE_COMMAND = {
      name: 'execute_command',
      description: 'Execute a terminal shell command on the host machine and return the stdout and stderr output.',
      parameters: {
        type: 'OBJECT',
        properties: {
          command: {
            type: 'STRING',
            description: 'The shell command to run (e.g., "ruby -v", "gem list colorize", "ls").'
          }
        },
        required: ['command']
      }
    }.freeze

    SIGNAL_COMPLETION = {
      name: 'signal_completion',
      description: 'Signal that the autonomous loop is done because the goal has either been met or is impossible to achieve.',
      parameters: {
        type: 'OBJECT',
        properties: {
          success: {
            type: 'BOOLEAN',
            description: 'True if the goal was successfully accomplished, false otherwise.'
          },
          message: {
            type: 'STRING',
            description: 'A detailed summary of the final state, achievements, or reasons for failure.'
          }
        },
        required: ['success', 'message']
      }
    }.freeze

    attr_reader :history, :diagnostic_log

    # Initialize the Terminal Agent.
    #
    # @param api_key [String] Google Gemini API Key.
    # @param max_iterations [Integer] Safety limit for continuous loop execution.
    def initialize(api_key: nil, max_iterations: 10)
      @gemini_client = GeminiApiClient.new(api_key: api_key)
      @max_iterations = max_iterations
      @history = []
      @diagnostic_log = []
    end

    # Reset the agent history and logs.
    def reset!
      @history = []
      @diagnostic_log = []
    end

    # Run the autonomous loop to achieve a specified goal.
    #
    # @param goal [String] The objective the user wants the agent to complete.
    # @yield [Hash] Yields execution status update logs to the caller for live terminal output.
    # @return [Hash] Final result of the execution.
    def run_goal(goal)
      reset!
      
      # Setup initial prompt in the chat history
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

        # Call Gemini API
        response_text, function_call = call_llm

        if response_text && !response_text.strip.empty?
          yield({ type: :agent_thought, text: response_text }) if block_given?
        end

        if function_call
          fn_name = function_call['functionCall']['name']
          fn_args = function_call['functionCall']['args'] || {}

          # Append the model's functionCall turn to the history to keep context correct
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

    # Execute a command, yield status events, and record result in history.
    #
    # @param cmd [String] The terminal command to run.
    def execute_command(cmd)
      yield({ type: :executing_command, text: cmd }) if block_given?

      output, status = run_terminal_command(cmd)
      yield({ type: :command_output, text: output, exit_status: status }) if block_given?

      @history << {
        role: 'user',
        parts: [{
          functionResponse: {
            name: 'execute_command',
            response: { content: output }
          }
        }]
      }
    end

    # Signal completion of the goal, yield completed event, and record in history.
    #
    # @param success [Boolean] True if completed successfully, false otherwise.
    # @param message [String] Completion detail message.
    def signal_completion(success, message)
      @history << {
        role: 'user',
        parts: [{
          functionResponse: {
            name: 'signal_completion',
            response: { content: 'Completion signal received.' }
          }
        }]
      }
      yield({ type: :completed, success: success, text: message }) if block_given?
    end

    # Handle an unknown or hallucinated function call.
    #
    # @param fn_name [String] The unknown function name.
    def handle_unknown_function(fn_name)
      err_msg = "Error: Function '#{fn_name}' is not supported by this agent."
      @history << {
        role: 'user',
        parts: [{
          functionResponse: {
            name: fn_name,
            response: { content: err_msg }
          }
        }]
      }
    end

    # Handle a response that contains only text, appending a nudge message to history.
    #
    # @param response_text [String] The text content returned by the model.
    def handle_text_only_response(response_text)
      nudge = "You did not request a tool call. Remember to use `execute_command` to execute terminal steps, or `signal_completion` if you have completed the goal."
      @history << {
        role: 'model',
        parts: [{ text: response_text || "" }]
      }
      @history << {
        role: 'user',
        parts: [{ text: nudge }]
      }
    end

    # Make the LLM call using the Gemini client, with built-in retry handling for transient API issues.
    def call_llm
      attempts = 3
      delay = 2
      tries = 0
      begin
        tries += 1
        @gemini_client.generate_content(
          SYSTEM_PROMPT,
          @history,
          tools: [{ functionDeclarations: [EXECUTE_COMMAND, SIGNAL_COMPLETION] }]
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

    # Safely execute a system command on the host.
    # Returns [String output, Process::Status status]
    def run_terminal_command(command)
      stdout_str, stderr_str, status = Open3.capture3(command)
      combined_output = "Exit Status: #{status.exitstatus}\n"
      unless stdout_str.empty?
        combined_output += "--- STDOUT ---\n#{stdout_str}"
      end
      unless stderr_str.empty?
        combined_output += "--- STDERR ---\n#{stderr_str}"
      end
      [combined_output, status]
    rescue StandardError => e
      ["Error executing command: #{e.message}", nil]
    end
  end
end
