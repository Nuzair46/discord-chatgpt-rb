# This code was generated automatically by ChatGPT itself.

require 'discordrb'
require 'ruby/openai'

# Set up a Discord client and authenticate with your bot token
client = Discordrb::Commands::CommandBot.new(token: ENV['DISCORD_TOKEN'], prefix: '!')

client.ready do
  client.stream('Red | !help', 'https://rednek46.me')
end

# Set up the OpenAI API client with your API key
openai_client = OpenAI::Client.new(access_token: ENV['OPENAI_API_KEY'])

# Define a command that generates a response using ChatGPT
client.command(:chat, description: 'Chat with ChatGPT') do |event, *prompt|
  # Use the OpenAI API to generate a response

  response = openai_client.completions(
    parameters: {
      model: 'text-davinci-003',
      prompt: prompt.join(' '),
      max_tokens: 1024
    }
  )

  # Send the response back to the channel
  begin
    event.message.reply! response['choices'][0]['text']
  rescue Discordrb::Errors::MessageTooLong => e
    event.message.reply! e.message
  end
end

# use dalle to generate images
client.command(:generate, description: 'Generate image with DALLE2') do |event, *prompt|
  response = openai_client.images.generate(parameters: { prompt: prompt.join(' ') })
  event.message.reply! response.dig('data', 0, 'url')
rescue RestClient::BadRequest
  event.message.reply! 'Image generation failed, Probably you asked something too weird.'
end

# Run the bot
client.run
