class FacebookPostWorker
  include Sidekiq::Worker
  sidekiq_options queue: :default
  require 'pry-remote'

  def perform(id, current_user_id)
    current_user = User.find_by(id: current_user_id)
    facebook_client(current_user)
    @post = Post.find_by(id: id)
    case @post.post_type
    when 'text'
      text_post(@post.description)
    when 'image_post'
      multiple_images_post(@post)
    when 'video_post'
      video_post(@post.video_url)
    when 'action_link'
      call_to_action(@post)
    end
  end

  def multiple_images_post(post)
    post_options_unpublished = { caption: post.title, published: false }
    pictures_to_share = post.images.split(', ')
    raise 'Not enough pictures' if pictures_to_share.size == 0

    pictures_fb_ids = []
    pictures_to_share.each do |image_url|
      fb = @graph_fb_page.put_picture(image_url, post_options_unpublished, 'me')
      pictures_fb_ids << fb['id']
    end
    post_options = { message: post.description }
    pictures_fb_ids.each_with_index do |pictures_fb_id, index|
      post_options["attached_media[#{index}]".to_sym] = "{'media_fbid':'#{pictures_fb_id}'}"
    end
    fb2 = @graph_fb_page.put_connections('me', 'feed', post_options)
  end

  ##============================================================##
  ## Facebook Video Post
  ##============================================================##
  def video_post(video_url)
    @graph_fb_page.put_video(video_url)
  end

  ##============================================================##
  ## Facebook Text Post
  ##============================================================##
  def text_post(body)
    @graph_fb_page.put_wall_post(body)
  end

  ##============================================================##
  ## Call To Action
  ##============================================================##
  def call_to_action(post)
    @fb =  @graph_fb_page.put_connections(@facebook.page_id, 'feed',
                                          message: post.description,
                                          link: post.action_link)
  end

  private

  def facebook_client(current_user)
    @facebook = current_user.accounts.last.facebook_pages.last
    @graph_fb = Koala::Facebook::API.new(@facebook.user_access_token)
    @graph_fb_page = Koala::Facebook::API.new(@facebook.page_access_token)
  end
end
