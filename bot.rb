################# LIBRARIES #################
# Configuration du twitter
require 'bundler/setup'
Bundler.require

require 'capybara/dsl'
################# ######### #################

################# CONFIGURATION #################
# Configuration du twitter
LOGIN = 'Your login'
PASSWORD = 'Your password'
HAS_PINNED_TWEET = true # Si un pinned tweet est present
WEBSITE_URL = 'https://twitter.com' # Ne pas changer cette valeur

# Configuration du bot Discord
DISCORD_TOKEN = 'Your discord token' # Remplacez YOUR_BOT_TOKEN par le token de votre bot Discord
DISCORD_CLIENT_ID = 'Your discord client id' # Remplacez YOUR_BOT_CLIENT_ID par l'ID de votre bot Discord
CHANNEL_ID = 'Your discord channel id' # Remplacez YOUR_CHANNEL_ID par l'ID du salon où vous souhaitez envoyer le message
CALL_WITH_MESSAGE = true # True pour utiliser le message
################# ############# #################

Capybara.register_driver :selenium do |app|
  options = Selenium::WebDriver::Chrome::Options.new
  # options.add_argument('--start-maximized') # DEBUG MODE - Ouvre Chrome en plein ecran
  options.add_argument('--headless') # Execution en mode headless
  options.add_argument('--disable-gpu') # Desactiver le rendu GPU (optionnel, parfois necessaire)
  Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
end

# Capybara.default_driver = :selenium # DEBUG MODE - Ouvre Chrome en mode normal
Capybara.default_driver = :selenium_headless # DEBUG MODE - Ouvre Chrome en mode headless
Capybara.current_driver = :selenium_headless # DEBUG MODE - Ouvre Chrome en mode headless
Capybara.app_host = WEBSITE_URL

class TwitterFetcher
  include Capybara::DSL

  def initialize
    visit('/')
  end

  def login(username, password)
    sleep(2)

    # Entrer le username
    element = find('input[type="text"]')
    element.click
    element.set(username)

    # Appuye sur le bouton suivant
    button = all('span', text: 'Suivant')[0]
    button.click

    sleep(2)

    # Entrer le password
    # element = find('input[type="text"]')
    fill_in('password', with: password)

    # Appuye sur le bouton se connecter
    button = all('span', text: 'Se connecter')[0]
    button.click

    sleep(2)
  end

  def get_url_from_last_tweet(has_pinned_tweet=false)
    sleep(2)

    # Gerer les cookies
    element = all('span', text: 'Refuse non-essential cookies')[0]
    element.click

    sleep(2)

    # Cliquer sur profile
    element = all('span', text: 'Profile')[0]
    element.click

    sleep(2)

    # Trouver le tweet
    tweet_index = if (has_pinned_tweet)
      1
    else
      0
    end
    element = all('div[data-testid="tweetText"]')[tweet_index]
    element.click

    sleep(2)

    # Retourner l'url
    Capybara.current_session.current_url
  end
end

bot = Discordrb::Bot.new token: DISCORD_TOKEN, client_id: DISCORD_CLIENT_ID

if CALL_WITH_MESSAGE
  bot.message(with_text: '!tweet') do |event|
    twitter_fetcher = TwitterFetcher.new
    pp "Log in on twitter"
    twitter_fetcher.login(LOGIN, PASSWORD)
    pp "Log in succeeded"
    tweet_url = twitter_fetcher.get_url_from_last_tweet(HAS_PINNED_TWEET)
    pp "Url is fetched"
    bot.send_message(CHANNEL_ID, tweet_url)
    pp "Message is sent to discord"
  end

  bot.message(with_text: '!stop_bot') do |event|
    bot.stop
    pp "Stop bot"
  end

  bot.run
else
  # Recupere le dernier tweet et post le message sur discord
  twitter_fetcher = TwitterFetcher.new
  pp "Log in on twitter"
  twitter_fetcher.login(LOGIN, PASSWORD)
  pp "Log in succeeded"
  tweet_url = twitter_fetcher.get_url_from_last_tweet(HAS_PINNED_TWEET)
  pp "Url is fetched"
  bot.send_message(CHANNEL_ID, tweet_url)
  pp "Message is sent to discord"
end
