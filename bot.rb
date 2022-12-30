# This code was generated automatically by ChatGPT itself.

require 'discordrb'
require 'openai'

# Set up a Discord client and authenticate with your bot token
client = Discordrb::Commands::CommandBot.new(token: ENV['DISCORD_TOKEN'], prefix: '!', help_command: false)

# Set up the OpenAI API client with your API key
OpenAI.api_key = ENV['OPENAI_API_KEY']

# Define a command that generates a response using ChatGPT
client.command(:chatgpt) do |event, *prompt|
  # Use the OpenAI API to generate a response
  response = OpenAI::Completion.create(
    model: 'chatgpt',
    prompt: prompt.join(' '),
    max_tokens: 1024,
    temperature: 0.5
  )

  # Send the response back to the channel
  event.respond(response.text)
end

# Run the bot
client.run
