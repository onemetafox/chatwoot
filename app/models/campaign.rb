# == Schema Information
#
# Table name: campaigns
#
#  id               :bigint           not null, primary key
#  background_info  :string
#  deleted_at       :datetime
#  description      :text
#  enabled          :boolean          default(TRUE)
#  message          :text             not null
#  subscribed_users :text
#  title            :string           not null
#  trigger_rules    :jsonb
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  account_id       :bigint           not null
#  display_id       :integer          not null
#  inbox_id         :bigint           not null
#  sender_id        :integer
#
# Indexes
#
#  index_campaigns_on_account_id  (account_id)
#  index_campaigns_on_inbox_id    (inbox_id)
#
# Foreign Keys
#
#  fk_rails_...  (account_id => accounts.id)
#  fk_rails_...  (inbox_id => inboxes.id)
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
  
  # /////////////////  FFCRM  //////////////////
  belongs_to :user, optional: true # TODO: Is this really optional?
  belongs_to :assignee, class_name: "User", foreign_key: :assigned_to, optional: true # TODO: Is this really optional?
  has_many :tasks, as: :asset, dependent: :destroy # , :order => 'created_at DESC'
  has_many :leads, -> { order "id DESC" }, dependent: :destroy
  has_many :opportunities, -> { order "id DESC" }, dependent: :destroy
  has_many :emails, as: :mediator

  serialize :subscribed_users, Set

  scope :state, lambda { |filters|
    where('status IN (?)' + (filters.delete('other') ? ' OR status IS NULL' : ''), filters)
  }
  scope :created_by,  ->(user) { where(user_id: user.id) }
  scope :assigned_to, ->(user) { where(assigned_to: user.id) }

  scope :text_search, ->(query) { ransack('name_cont' => query).result }

  # uses_user_permissions
  # acts_as_commentable
  # uses_comment_extensions
  # acts_as_taggable_on :tags
  # has_paper_trail versions: { class_name: 'Version' }, ignore: [:subscribed_users]
  # has_fields
  # exportable
  # sortable by: ["name ASC", "target_leads DESC", "target_revenue DESC", "leads_count DESC", "revenue DESC", "starts_on DESC", "ends_on DESC", "created_at DESC", "updated_at DESC"], default: "created_at DESC"

  has_ransackable_associations %w[leads opportunities tags activities emails comments tasks]
  ransack_can_autocomplete

  validates_presence_of :name, message: :missing_campaign_name
  validates_uniqueness_of :name, scope: %i[user_id deleted_at]
  validate :start_and_end_dates
  validate :users_for_shared_access
  validates :status, inclusion: { in: proc { Setting.unroll(:campaign_status).map { |s| s.last.to_s } } }, allow_blank: true

  # Default values provided through class methods.
  #----------------------------------------------------------------------------
  def self.per_page
    20
  end

  # Attach given attachment to the campaign if it hasn't been attached already.
  #----------------------------------------------------------------------------
  def attach!(attachment)
    unless send("#{attachment.class.name.downcase}_ids").include?(attachment.id)
      if attachment.is_a?(Task)
        send(attachment.class.name.tableize) << attachment
      else # Leads, Opportunities
        attachment.update_attribute(:campaign, self)
        attachment.send("increment_#{attachment.class.name.tableize}_count")
        [attachment]
      end
    end
  end

  # Discard given attachment from the campaign.
  #----------------------------------------------------------------------------
  def discard!(attachment)
    if attachment.is_a?(Task)
      attachment.update_attribute(:asset, nil)
    else # Leads, Opportunities
      attachment.send("decrement_#{attachment.class.name.tableize}_count")
      attachment.update_attribute(:campaign, nil)
    end
  end
  # /////////////////////////////////////////////////////////////////////////
  def users_for_shared_access
    errors.add(:access, :share_campaign) if self[:access] == "Shared" && permissions.none?
  end
  private

  def set_display_id
    reload
  end

  # creating db triggers
  trigger.before(:insert).for_each(:row) do
    "NEW.display_id := nextval('camp_dpid_seq_' || NEW.account_id);"
  end
end
