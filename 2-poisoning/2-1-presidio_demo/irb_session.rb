# frozen_string_literal: true

require_relative 'lib/presidio_client'

# Custom String extensions for terminal colors inside IRB
class String
  def colorize(code)
    "\e[#{code}m#{self}\e[0m"
  end

  def swap
    "\e[7m#{self}\e[0m"
  end

  def bold
    "\e[1m#{self}\e[0m"
  end
end

puts "\n" + "═" * 60
puts " 💎 MICROSOFT PRESIDIO RUBY INTEGRATION - IRB DEMO 💎 ".colorize(36).swap
puts "═" * 60
puts "We have pre-instantiated a ".colorize(37) + "PresidioClient".colorize(32).bold + " instance for you as '" + "client".colorize(33).bold + "'."
puts "You can run anonymization and neutralization queries directly."
puts "\nTry executing the following commands in this interactive shell:"
puts "  * " + "client.anonymize(\"Hi, my name is John Doe, my email is john@example.com\")".colorize(95)
puts "  * " + "puts JSON.pretty_generate(client.anonymize(\"Call me at +551195311111111\"))".colorize(95)
puts "═" * 60 + "\n\n"

# Instantiate client for immediate use in the IRB session
client = Chatbots::PresidioClient.new

# Launch interactive IRB session with the local context loaded
binding.irb
