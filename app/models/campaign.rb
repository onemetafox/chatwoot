# == Schema Information
#
# Table name: campaigns
#
#  id                  :bigint           not null, primary key
#  access              :string(8)        default("Public")
#  assigned_to         :integer
#  background_info     :string
#  budget              :decimal(12, 2)
#  deleted_at          :datetime
#  ends_on             :date
#  leads_count         :integer
#  name                :string(64)       default(""), not null
#  objectives          :text
#  opportunities_count :integer
#  revenue             :decimal(12, 2)
#  starts_on           :date
#  status              :string(64)
#  subscribed_users    :text
#  target_conversion   :float
#  target_leads        :integer
#  target_revenue      :decimal(12, 2)
#  created_at          :datetime
#  updated_at          :datetime
#  user_id             :integer
#
# Indexes
#
#  index_campaigns_on_assigned_to                      (assigned_to)
#  index_campaigns_on_user_id_and_name_and_deleted_at  (user_id,name,deleted_at) UNIQUE
#
class Campaign < ApplicationRecord
  validates :account_id, presence: true
  validates :inbox_id, presence: true
  validates :title, presence: true
  validates :message, presence: true
  belongs_to :account
  belongs_to :inbox
  belongs_to :sender, class_name: 'User', optional: true

  has_many :conversations, dependent: :nullify, autosave: true

  after_commit :set_display_id, unless: :display_id?

  private

  def set_display_id
    reload
  end

  # creating db triggers
  trigger.before(:insert).for_each(:row) do
    "NEW.display_id := nextval('camp_dpid_seq_' || NEW.account_id);"
  end
end
