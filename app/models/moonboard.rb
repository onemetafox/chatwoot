# == Schema Information
#
# Table name: moonboards
#
#  id         :bigint           not null, primary key
#  title      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  account_id :bigint           not null
#
# Indexes
#
#  index_moonboards_on_account_id  (account_id)
#
# Foreign Keys
#
#  fk_rails_...  (account_id => accounts.id)
#
class Moonboard < ApplicationRecord
    belongs_to :account
    has_many :moonboard_items, dependent: :destroy
  
  end
