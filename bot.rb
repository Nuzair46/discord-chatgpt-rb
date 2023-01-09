# This code was generated automatically by ChatGPT itself.

require 'discordrb'
require 'ruby/openai'

# Set up a Discord client and authenticate with your bot token
client = Discordrb::Commands::CommandBot.new(token: ENV['DISCORD_TOKEN'], prefix: '!')

client.ready do
  client.game = 'by Red | !help', 'https://rednek46.me'
end

# setting up bucket
@rate_limiter = Discordrb::Commands::SimpleRateLimiter.new
@rate_limiter.bucket :api_limit, limit: ENV['RATE_LIMIT'], time_span: ENV['RATE_LIMIT_SPAN'],
                                 delay: ENV['RATE_LIMIT_DELAY']

# Set up the OpenAI API client with your API key
openai_client = OpenAI::Client.new(access_token: ENV['OPENAI_API_KEY'])

# Define a command that generates a response using ChatGPT
client.command(:chat, description: 'Chat with ChatGPT') do |event, *prompt|
  next if rate_limited?(event)

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
  next if rate_limited?(event)

  response = openai_client.images.generate(parameters: { prompt: prompt.join(' ') })
  event.message.reply! response.dig('data', 0, 'url')
rescue RestClient::BadRequest
  event.message.reply! 'Image generation failed, Probably you asked something too weird.'
end

def rate_limited?(event)
  return false if skip_rate_limit?(event)

  time = @rate_limiter.rate_limited?(:api_limit, event.user)
  return false unless time

  event.message.reply! "You are being rate limited. Please try again after #{time} seconds."
end

def skip_rate_limit?(event)
  owner?(event.user.id) || rate_limit_server_whitelist(event.server.id)
end

def owner?(user_id)
  user_id == ENV['OWNER_ID']
end

def rate_limit_server_whitelist(server_id)
  server_list = ENV['RATE_LIMIT_SERVER_WHITELIST']&.split(',') || []
  server_list.include?(server_id)
end

# Run the bot
client.run
