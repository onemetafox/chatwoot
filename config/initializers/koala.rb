Koala.configure do |config|
  # config.access_token = MY_TOKEN
  config.api_version = 'v2.0'
  config.app_access_token = ENV['FB_VERIFY_TOKEN']
  config.app_id = ENV['FB_APP_ID']
  config.app_secret = ENV['FB_APP_SECRET']
end
