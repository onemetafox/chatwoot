Rails.application.config.middleware.use OmniAuth::Builder do
  provider :facebook, ENV['FB_APP_ID'], ENV['FB_APP_SECRET'],
           {
             :scope            => "public_profile, pages_manage_metadata, pages_read_engagement, pages_read_user_content, pages_manage_engagement, pages_manage_posts, pages_manage_ads",
             :display          => "page",
             :image_size       => "square",
             :secure_image_url =>  true
           }
end
