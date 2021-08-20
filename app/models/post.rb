# == Schema Information
#
# Table name: posts
#
#  id              :bigint           not null, primary key
#  action_link     :string
#  description     :text
#  images          :string
#  post_type       :string
#  postable_type   :string
#  scheduled_at    :datetime
#  social_platform :string
#  title           :string
#  video_url       :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  postable_id     :bigint
#
# Indexes
#
#  index_posts_on_postable_type_and_postable_id  (postable_type,postable_id)
#
class Post < ApplicationRecord

end
