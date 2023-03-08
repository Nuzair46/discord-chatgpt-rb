# The intitial commit code was generated automatically by ChatGPT itself.

require 'discordrb'
require 'ruby/openai'

# Set up a Discord client and authenticate with your bot token
client = Discordrb::Commands::CommandBot.new(token: ENV['DISCORD_TOKEN'], prefix: '!')

client.ready do
  client.stream('Red.#1111 | !help', 'https://redisa.dev')
end

# setting up bucket
@rate_limiter = Discordrb::Commands::SimpleRateLimiter.new
@rate_limiter.bucket :api_limit, limit: ENV['RATE_LIMIT'].to_i, time_span: ENV['RATE_LIMIT_SPAN'].to_i,
                                 delay: ENV['RATE_LIMIT_DELAY'].to_i

# Set up the OpenAI API client with your API key
openai_client = OpenAI::Client.new(access_token: ENV['OPENAI_API_KEY'])

# Define a command that generates a response using ChatGPT
client.command(:chat, description: 'Chat with ChatGPT') do |event, *prompt|
  if prompt.empty?
    event.message.reply! 'You need to ask something.'
    next
  end
  next if rate_limited?(event)

  # Use the OpenAI API to generate a response
  response = openai_client.chat(
    parameters: {
      model: 'gpt-3.5-turbo',
      messages: [{ role: 'user', content: prompt.join(' ') }],
      temperature: 0.7
    }
  )

  # Send the response back to the channel
  begin
    next event.message.reply! 'Low on credits.' if response['error']

    event.message.reply! response.dig('choices', 0, 'message', 'content')
  rescue Discordrb::Errors::MessageTooLong => e
    event.message.reply! e.message
  end
end

# use dalle to generate images
client.command(:generate, description: 'Generate image with DALLE2') do |event, *prompt|
  if prompt.empty?
    event.message.reply! 'You need to ask something.'
    next
  end
  next if rate_limited?(event)

  response = openai_client.images.generate(parameters: { prompt: prompt.join(' ') })
  event.message.reply! response.dig('data', 0, 'url')
rescue RestClient::BadRequest
  event.message.reply! 'Image generation failed, Probably you asked something too weird or low on credits.'
end

# meowGPT
client.command(:meow, description: 'Meow with MeowGPT') do |event, *prompt|
  if prompt.empty?
    event.message.reply! 'Meow?'
    next
  end
  meow = 'meow'
  count = prompt.count
  basic_sentence = "#{meow} " * count
  stoppers = ['.', '?', '!']
  stopper = stoppers.sample
  sentence = "#{basic_sentence.strip}#{stopper}".capitalize
  sentence = sentence.upcase if count <= 5 && ['.', '!'].include?(stopper)
  event.message.reply! sentence
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
  user_id.to_s == ENV['OWNER_ID']
end

def rate_limit_server_whitelist(server_id)
  server_list = ENV['RATE_LIMIT_SERVER_WHITELIST']&.split(',') || []
  server_list.include?(server_id.to_s)
end

# Run the bot
client.run
