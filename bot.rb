# This code was generated automatically by ChatGPT itself.

require 'discordrb'
require 'ruby/openai'

# Set up a Discord client and authenticate with your bot token
client = Discordrb::Commands::CommandBot.new(token: ENV['DISCORD_TOKEN'], prefix: '!', help_command: false)

# Set up the OpenAI API client with your API key
openai_client = OpenAI::Client.new(access_token: ENV['OPENAI_API_KEY'])

# Define a command that generates a response using ChatGPT
client.command(:chat) do |event, *prompt|
  # Use the OpenAI API to generate a response

  response = openai_client.completions(
    parameters: {
      model: 'text-davinci-003',
      prompt: prompt.join(' '),
      max_tokens: 1024
    }
  )

  # Send the response back to the channel
  event.respond response['choices'][0]['text']
end

# Run the bot
client.run
