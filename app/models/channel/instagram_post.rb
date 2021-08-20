# == Schema Information
#
# Table name: channel_instagram_posts
#
#  id                :bigint           not null, primary key
#  page_access_token :string           not null
#  post_link         :string
#  user_access_token :string           not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  accounts_id       :bigint           not null
#  page_id           :string           not null
#
# Indexes
#
#  index_channel_instagram_posts_on_accounts_id  (accounts_id)
#
class Channel::InstagramPost < ApplicationRecord
  has_many :posts, as: :postable

end
