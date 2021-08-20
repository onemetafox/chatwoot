class TwitterPostWorker
  include Sidekiq::Worker
  sidekiq_options :queue => :default
  def perform(id)
    set_twitter_client
    @post = Post.find_by(id: id)
    @twitter_folder = "#{Rails.root}/tmp/twitter_post/#{@post.id}"
    FileUtils.mkdir_p(@twitter_folder) unless File.exists?(@twitter_folder)
    case @post.post_type
    when 'text'
      text_post
    when 'images'
      publish_photos(@post.images)
    when 'video'
      publish_video
    end
  end

  def text_post
    @client.update(@post.description)
  end

  def publish_video
    begin
      raise I18n.t('videos.error_not_found') if video_url.blank?
      pusher_and_log(I18n.t("twitter.worker.sending_medias"), 30)
      twitter_video = "#{@twitter_folder}/#{File.basename(video)}"
      open(twitter_video, 'wb') { |file| file.write HTTParty.get(video_url).body }
      pusher_and_log(I18n.t("twitter.worker.sending"), 50)
      t_video = @client.send(:upload, File.new(twitter_video))
      pusher_and_log(I18n.t("twitter.worker.sending_tweet"), 80)
      uid = @client.update(@post.description, media_ids: t_video[:media_id]).id
      # uid       = @client.update_with_media(@tweet, File.new(twitter_video)).id
    end
  end

  def publish_photos(images)
    begin
      media_ids = []
      pic_array = images.split(', ')
      ##============================================================##
      ## Send picture to Tweeter servers
      ##============================================================##
      pic_array.each_with_index do |picture_url, index|
        next if index > 3
        twitter_image = "#{@twitter_folder}/#{File.basename(picture_url)}"
        open(twitter_image, 'wb') { |file| file.write HTTParty.get(picture_url).body }
        t_image = @client.send(:upload, File.new(twitter_image))
        media_ids << t_image[:media_id]
      end if pic_array.size > 0
      ##============================================================##
      ## Send Tweet with pictures
      ##============================================================##
      uid = @client.update(@post.description, media_ids: media_ids.join(',')).id
    end
  end
  private
  def set_twitter_client
    @twitter_profile = Channel::TwitterProfile.where(account_id: current_user.accounts.pluck(:id)).last
    @client = Twitter::REST::Client.new do |config|
      config.consumer_key = ENV.fetch('TWITTER_CONSUMER_KEY', nil)
      config.consumer_secret = ENV.fetch('TWITTER_CONSUMER_SECRET', nil)
      config.access_token        = @twitter_profile.twitter_access_token
      config.access_token_secret = @twitter_profile.twitter_access_token_secret
    end
  end
end
