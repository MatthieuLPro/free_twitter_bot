require 'discordrb'
require 'twitter'

# Configuration du bot Discord
bot_token = 'YOUR_BOT_TOKEN' # Remplacez YOUR_BOT_TOKEN par le token de votre bot Discord
bot_client_id = 'YOUR_BOT_CLIENT_ID' # Remplacez YOUR_BOT_CLIENT_ID par l'ID de votre bot Discord
server_id = 'YOUR_SERVER_ID' # Remplacez YOUR_SERVER_ID par l'ID de votre serveur Discord
channel_id = 'YOUR_CHANNEL_ID' # Remplacez YOUR_CHANNEL_ID par l'ID du salon où vous souhaitez envoyer le message

# Configuration de l'API Twitter
twitter_consumer_key = 'YOUR_TWITTER_CONSUMER_KEY' # Remplacez YOUR_TWITTER_CONSUMER_KEY par la clé d'API de votre application Twitter
twitter_consumer_secret = 'YOUR_TWITTER_CONSUMER_SECRET' # Remplacez YOUR_TWITTER_CONSUMER_SECRET par le secret d'API de votre application Twitter
twitter_access_token = 'YOUR_TWITTER_ACCESS_TOKEN' # Remplacez YOUR_TWITTER_ACCESS_TOKEN par le jeton d'accès de votre compte Twitter
twitter_access_token_secret = 'YOUR_TWITTER_ACCESS_TOKEN_SECRET' # Remplacez YOUR_TWITTER_ACCESS_TOKEN_SECRET par le secret du jeton d'accès de votre compte Twitter

# Création du client Discord
bot = Discordrb::Bot.new token: bot_token, client_id: bot_client_id

# Création du client Twitter
twitter_client = Twitter::REST::Client.new do |config|
  config.consumer_key = twitter_consumer_key
  config.consumer_secret = twitter_consumer_secret
  config.access_token = twitter_access_token
  config.access_token_secret = twitter_access_token_secret
end

# Événement de création d'un tweet
bot.message(with_text: '!tweet') do |event|
  latest_tweet = twitter_client.user_timeline('YOUR_TWITTER_USERNAME').first # Remplacez YOUR_TWITTER_USERNAME par votre nom d'utilisateur Twitter
  event.channel.send_message("Nouveau tweet : #{latest_tweet.url}")
end

# Démarrage du bot Discord
bot.run