class Api::V1::SocialPostsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create_twitter_post
    @twitter_profile = Channel::TwitterProfile.where(account_id: User.last.accounts.pluck(:id)).last
    twitter_client.update_with_media 'USama Tweet', File.new('index.jpeg')
  end

  private

  def twitter_client
    @client = Twitter::REST::Client.new do |config|
      config.consumer_key        = ENV.fetch('TWITTER_CONSUMER_KEY', nil)
      config.consumer_secret     = ENV.fetch('TWITTER_CONSUMER_SECRET', nil)
      config.access_token        = @twitter_profile.twitter_access_token
      config.access_token_secret = @twitter_profile.twitter_access_token_secret
    end
  end



end
