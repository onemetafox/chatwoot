class Api::V1::SocialMediaPostsController < Api::BaseController
  before_action :posts_params

  def create
    @post = Post.new(posts_params)
    @post.images = params[:social_media_posts][:images].join(', ')
    if @post.save!
      case @post.social_platform
      when 'facebook'
        if @post.scheduled_at.present?
          FacebookPostWorker.perform_at(@post.scheduled_at.to_time, @post.id, current_user.id)
        else
          FacebookPostWorker.perform_in(0, @post.id, current_user.id)
        end
      when 'instagram'
        if @post.scheduled_at.present?
          InstagramPostWorker.perform_in(@post.scheduled_at.to_time, @post.id, current_user.id)
        else
          InstagramPostWorker.perform_in(0, @post.id, current_user.id)
        end
      when 'twitter'
        if @post.scheduled_at.present?
          TwitterPostWorker.perform_in(@post.scheduled_at.to_time, @post.id, current_user.id)
        else
          TwitterPostWorker.perform_in(0, @post.id, current_user.id)
        end
      end
    end
    # end
  end

  private
  def posts_params
    params.require(:social_media_posts).permit(:title, :description, :post_type, :video_url, :action_link, :social_platform, images: [])
  end
end
