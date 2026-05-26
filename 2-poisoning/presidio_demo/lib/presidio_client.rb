# frozen_string_literal: true

require 'open3'
require 'json'

module Chatbots
  class PresidioClient
    def initialize
      @helper_path = File.expand_path('presidio_helper.py', __dir__)
      @stdin = nil
      @stdout = nil
      @wait_thr = nil
      start_process!
    end

    # Send a text string to Presidio helper to anonymize and neutralize
    #
    # @param text [String] The raw text input
    # @return [Hash] Parsed results from python helper
    def anonymize(text)
      ensure_process_alive!
      payload = { action: 'anonymize', text: text }.to_json
      @stdin.puts(payload)
      
      response_line = @stdout.gets
      raise 'Presidio subprocess connection closed unexpectedly.' if response_line.nil?

      JSON.parse(response_line, symbolize_names: true)
    rescue StandardError => e
      # Attempt a recovery restart on next call
      close_process
      { success: false, error: e.message }
    end

    def close
      close_process
    end

    private

    def start_process!
      # Start python3 subprocess running presidio_helper.py
      # We use python3 -u for unbuffered stdout to ensure immediate response lines
      @stdin, @stdout, @wait_thr = Open3.popen2('python3', '-u', @helper_path)
    rescue StandardError => e
      raise "Failed to start Presidio Python helper at #{@helper_path}: #{e.message}"
    end

    def ensure_process_alive!
      if @wait_thr.nil? || !@wait_thr.alive?
        start_process!
      end
    end

    def close_process
      return unless @stdin

      begin
        @stdin.close
      rescue StandardError
        nil
      end
      begin
        Process.kill('TERM', @wait_thr.pid) if @wait_thr&.alive?
      rescue StandardError
        nil
      end
      @stdin = nil
      @stdout = nil
      @wait_thr = nil
    end
  end
end
