# == Schema Information
#
# Table name: moonboard_items
#
#  id           :bigint           not null, primary key
#  position     :integer
#  text         :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  moonboard_id :bigint           not null
#
# Indexes
#
#  index_moonboard_items_on_moonboard_id  (moonboard_id)
#
# Foreign Keys
#
#  fk_rails_...  (moonboard_id => moonboards.id)
#
class MoonboardItem < ApplicationRecord
    belongs_to :moonboard
    has_one_attached :image, dependent: :destroy
    default_scope { order(position: :asc) }
  
    def image_url
      url_for(image) if image.present?
    end
  
    def thumbnail_url
      url_for(image.variant(resize: '200x')) if image.present?
    end
  end
