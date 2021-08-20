class InstagramPostWorker
  include Sidekiq::Worker
  sidekiq_options queue: :default

  def perform(id, currnt_user_id)
    current_user = User.find_by_id(currnt_user_id)
    @post = Post.find_by(id: id)
    set_page_id(current_user)
    case @post.post_type
    when 'image_post'
      single_image_post(@post)
    when 'video_post'
      instagram_video_post(@post)
    end
  end

  def single_image_post(media)
    ##============================================================##
    ## Instagram single photo post
    ##============================================================##
    query = {
      'image_url' => media.images,
      'caption' => media.title,
      'access_token' => @facebook.user_access_token
    }
    container_id = HTTParty.post("https://graph.facebook.com/v9.0/#{@business_account_page_id}/media",
                                  query: query
    )
    @container_id = container_id['id']

    sleep(10.seconds)
    container_status = HTTParty.get("https://graph.facebook.com/v9.0/#{@container_id}?fields=status_code&access_token=#{@facebook.user_access_token}")
    if container_status['status_code'] == 'FINISHED'
      query = {
        'creation_id' => @container_id,
        'access_token' => @facebook.user_access_token
      }
      post_id = HTTParty.post(
        "https://graph.facebook.com/v9.0/#{@business_account_page_id}/media_publish",
        query: query
      )
    else
      sleep(10.seconds)
      query = {
        'creation_id' => @container_id,
        'access_token' =>@facebook.user_access_token
      }
      post_id = HTTParty.post(
        "https://graph.facebook.com/v9.0/#{@business_account_page_id}/media_publish",
        query: query
      )
    end
  end

  ##============================================================##
  ## Instagram video post
  ##============================================================##
  def instagram_video_post(media)
    video_query = {
      'media_type' => 'VIDEO',
      'video_url' => media.video_url,
      'caption' => media.description,
      'access_token' => @facebook.user_access_token
    }
    container_id = HTTParty.post(
      "https://graph.facebook.com/v9.0/#{@business_account_page_id}/media",
      query: video_query
    )
    sleep(10.seconds)
    @container_id = container_id['id']
    container_status = HTTParty.get("https://graph.facebook.com/v9.0/#{@container_id}?fields=status_code&access_token=#{@facebook.user_access_token}")
    if container_status['status_code'] == 'FINISHED'
      query = {
        'creation_id' => @container_id,
        'access_token' => @facebook.user_access_token
      }
      post_id = HTTParty.post(
        "https://graph.facebook.com/v9.0/#{@business_account_page_id}/media_publish",
        query: query
      )
    else
      sleep(10.seconds)
      query = {
        'creation_id' => @container_id,
        'access_token' => ENV['FB_VERIFY_TOKEN']
      }
      post_id = HTTParty.post(
        "https://graph.facebook.com/v9.0/#{@business_account_page_id}/media_publish",
        query: query
      )
    end
  end

  private

  def set_page_id(current_user)
    @facebook = current_user.accounts.last.facebook_pages.last
    @graph_fb_page = Koala::Facebook::API.new(@facebook.page_access_token)
    response = HTTParty.get("https://graph.facebook.com/v11.0/#{@facebook.page_id}?fields=instagram_business_account&access_token=#{@facebook.user_access_token}")
    @business_account_page_id = response['instagram_business_account']['id']
  end
end
