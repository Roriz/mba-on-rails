# frozen_string_literal: true

# Custom String extensions for terminal colors without external dependencies
class String
  COLORS = {
    red: 31, green: 32, yellow: 33, blue: 34, magenta: 35, cyan: 36,
    light_black: 90, light_red: 91, light_green: 92, light_yellow: 93,
    light_blue: 94, light_magenta: 95, light_cyan: 96, white: 97
  }.freeze

  def colorize(color)
    code = COLORS[color] || 37
    "\e[#{code}m#{self}\e[0m"
  end

  def swap
    "\e[7m#{self}\e[0m"
  end

  def bold
    "\e[1m#{self}\e[0m"
  end
end

# Reusable terminal chat loop runner for all interactive modules.
class InteractiveChatRunner
  # Load .env variables looking up the directory structure.
  #
  # @param file_path [String] Path to env file.
  def self.load_env(file_path)
    return unless File.exist?(file_path)

    File.readlines(file_path).each do |line|
      next if line.strip.empty? || line.strip.start_with?('#')

      key, val = line.strip.split('=', 2)
      ENV[key.strip] = val.strip.sub(/\A['"]/, '').sub(/['"]\z/, '') if key
    end
  end

  # Setup standard env and validation.
  def self.setup_environment!
    [
      File.expand_path('../.env', __dir__),
      File.expand_path('../../.env', __dir__),
      File.expand_path('../../../.env', __dir__)
    ].uniq.each { |path| load_env(path) }

    return unless ENV['GEMINI_API_KEY'].nil? || ENV['GEMINI_API_KEY'].empty?

    puts "\n[!] ERROR: GEMINI_API_KEY is not set.".colorize(:red)
    puts 'Please create a '.colorize(:yellow) + '.env'.colorize(:light_blue) + ' file in the root of the project with:'.colorize(:yellow)
    puts "GEMINI_API_KEY=your_api_key_here\n\n".colorize(:light_cyan)
    exit 1
  end

  # Initialize the chat runner with metadata and configuration.
  #
  # @param title [String] Banners and headings.
  # @param intro [String] Initial chatbot greeting.
  # @param color [Symbol] Color theme for the banner.
  # @param assistant_class [Class] The class of the assistant to initialize.
  #
  # Usage Example:
  #   InteractiveChatRunner.new(title: 'Demo', intro: 'Hi', assistant_class: HelloAssistant).run!
  def initialize(title:, intro:, color:, assistant_class:)
    @title = title
    @intro = intro
    @color = color
    @assistant_class = assistant_class
  end

  # Start the interactive chat REPL loop.
  def run!
    print_banner
    assistant = @assistant_class.new
    puts "#{'Bot: '.colorize(:green)}#{@intro}"

    loop do
      print "\nYou: ".colorize(:blue)
      input = $stdin.gets
      break if input.nil?

      input = input.strip
      next if input.empty?

      break if handle_command(input, assistant)
    end
  end

  private

  # Print the stylized terminal banner.
  def print_banner
    puts "\n#{'=' * 60}"
    puts @title.center(60).colorize(@color).swap
    puts '=' * 60
    puts 'Type '.colorize(:light_black) + '/reset'.colorize(:cyan) + ' to clear chat history.'.colorize(:light_black)
    puts 'Type '.colorize(:light_black) + '/history'.colorize(:magenta) + ' to see the full raw prompt payload.'.colorize(:light_black)
    puts 'Type '.colorize(:light_black) + '/exit'.colorize(:red) + ' to quit the chat.'.colorize(:light_black)
    puts '=' * 60
    puts " 🎓 [EDUCATIONAL PLAYGROUND] Verbose developer traces are ACTIVE!".colorize(:light_yellow).bold
    puts "  Every Gemini API request, system instruction(s) payload, and local tool"
    puts "  execution step will be logged inline to teach you the LLM mechanics."
    puts "#{'=' * 60}\n"
  end

  # Parse and execute commands or trigger AI completion.
  #
  # @param input [String] User input.
  # @param assistant [Object] Assistant instance.
  # @return [Boolean] True to terminate the REPL loop.
  def handle_command(input, assistant)
    case input.downcase
    when '/exit'
      puts "\nGoodbye!".colorize(:yellow)
      return true
    when '/reset'
      assistant.reset!
      puts "\n[System] Chat history reset.".colorize(:cyan)
      puts "#{'Bot: '.colorize(:green)}#{@intro}"
    when '/history'
      print_history(assistant)
    else
      generate_response(input, assistant)
    end
    false
  end

  # Display the formatted prompt payload history.
  #
  # @param assistant [Object] Assistant instance.
  def print_history(assistant)
    puts "\n#{'-' * 60}"
    puts ' RAW CHAT HISTORY (PAYLOAD SENT TO GEMINI) '.center(60).colorize(:magenta).swap
    puts '-' * 60
    assistant.history.each_with_index do |turn, idx|
      role_color = turn[:role] == 'user' ? :blue : :green
      puts "\n[Turn #{idx + 1}] Role: #{turn[:role].to_s.upcase}".colorize(role_color).bold
      print_parts(turn[:parts])
    end
    puts "#{'-' * 60}\n"
  end

  # Print history part payload cleanly.
  #
  # @param parts [Array, Hash, String] Prompt payload parts.
  def print_parts(parts)
    parts_list = parts.is_a?(Array) ? parts : [parts]
    parts_list.each do |part|
      if part.is_a?(Hash) && (part.key?(:text) || part.key?('text'))
        puts part[:text] || part['text']
      else
        puts part.to_json
      end
    end
  end

  # Generate and print response from the assistant.
  #
  # @param input [String] User prompt.
  # @param assistant [Object] Assistant instance.
  def generate_response(input, assistant)
    print 'Bot is thinking...'.colorize(:light_black)
    response = assistant.chat(input)
    print "\r#{' ' * 30}\r"

    print_diagnostics(assistant)

    if response.start_with?('Error:')
      puts 'Bot: '.colorize(:green) + response.colorize(:red)
    else
      puts 'Bot: '.colorize(:green) + response.colorize(:light_green)
    end
  end

  # Print diagnostic logs if supported by the assistant.
  #
  # @param assistant [Object] Assistant instance.
  def print_diagnostics(assistant)
    return unless assistant.respond_to?(:diagnostic_log) && assistant.diagnostic_log.any?

    puts "\n#{'═' * 60}"
    puts ' 🔍 INTERCEPTOR PIPELINE DIAGNOSTIC TRACE 🔍 '.center(60).colorize(:cyan).swap
    puts '═' * 60
    assistant.diagnostic_log.each do |log|
      puts "▶ #{log[:phase].colorize(:light_yellow).bold}"
      puts log[:details].colorize(:white)
      puts '─' * 60
    end
    puts "\n"
  end
end
