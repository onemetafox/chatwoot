# == Schema Information
#
# Table name: accounts
#
#  id                    :integer          not null, primary key
#  access                :string(8)        default("Public")
#  assigned_to           :integer
#  auto_resolve_duration :integer
#  background_info       :string
#  category              :string(32)
#  contacts_count        :integer          default(0)
#  deleted_at            :datetime
#  domain                :string(100)
#  email                 :string(254)
#  fax                   :string(32)
#  feature_flags         :integer          default(0), not null
#  locale                :integer          default("en")
#  name                  :string(64)       default(""), not null
#  opportunities_count   :integer          default(0)
#  phone                 :string(32)
#  rating                :integer          default(0), not null
#  settings_flags        :integer          default(0), not null
#  subscribed_users      :text
#  support_email         :string(100)
#  toll_free_phone       :string(32)
#  uuid                  :string
#  website               :string(64)
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  user_id               :integer
#  users_id              :bigint
#
# Indexes
#
#  index_accounts_on_assigned_to                      (assigned_to)
#  index_accounts_on_user_id_and_name_and_deleted_at  (user_id,name,deleted_at) UNIQUE
#  index_accounts_on_users_id                         (users_id)
#

class Account < ApplicationRecord
  # used for single column multi flags
  include FlagShihTzu
  include Reportable
  include Featurable

  DEFAULT_QUERY_SETTING = {
    flag_query_mode: :bit_operator
  }.freeze

  ACCOUNT_SETTINGS_FLAGS = {
    1 => :custom_email_domain_enabled
  }.freeze

  validates :name, presence: true
  validates :auto_resolve_duration, numericality: { greater_than_or_equal_to: 1, allow_nil: true }
  
  #  ////////////////////   FFCRM   ///////////////////////////////
  belongs_to :user, optional: true # TODO: Is this really optional?
  belongs_to :assignee, class_name: "User", foreign_key: :assigned_to, optional: true
  has_many :account_contacts, dependent: :destroy
  has_many :contacts, -> { distinct }, through: :account_contacts
  has_many :account_opportunities, dependent: :destroy
  has_many :opportunities, -> { order("opportunities.id DESC").distinct }, through: :account_opportunities
  has_many :pipeline_opportunities, -> { order("opportunities.id DESC").distinct.pipeline }, through: :account_opportunities, source: :opportunity
  has_many :tasks, as: :asset, dependent: :destroy # , :order => 'created_at DESC'
  has_one :billing_address, -> { where(address_type: "Billing") }, dependent: :destroy, as: :addressable, class_name: "Address"
  has_one :shipping_address, -> { where(address_type: "Shipping") }, dependent: :destroy, as: :addressable, class_name: "Address"
  has_many :addresses, dependent: :destroy, as: :addressable, class_name: "Address" # advanced search uses this
  has_many :emails, as: :mediator

  #  //////////////////////// //// ///////////////////////


  has_many :account_users, dependent: :destroy
  has_many :agent_bot_inboxes, dependent: :destroy
  has_many :agent_bots, dependent: :destroy
  has_many :data_imports, dependent: :destroy
  has_many :users, through: :account_users
  has_many :inboxes, dependent: :destroy
  has_many :campaigns, dependent: :destroy
  has_many :conversations, dependent: :destroy
  has_many :messages, dependent: :destroy
  has_many :contacts, dependent: :destroy
  has_many :facebook_pages, dependent: :destroy, class_name: '::Channel::FacebookPage'
  has_many :telegram_bots, dependent: :destroy
  has_many :twilio_sms, dependent: :destroy, class_name: '::Channel::TwilioSms'
  has_many :twitter_profiles, dependent: :destroy, class_name: '::Channel::TwitterProfile'
  has_many :web_widgets, dependent: :destroy, class_name: '::Channel::WebWidget'
  has_many :email_channels, dependent: :destroy, class_name: '::Channel::Email'
  has_many :api_channels, dependent: :destroy, class_name: '::Channel::Api'
  has_many :canned_responses, dependent: :destroy
  has_many :webhooks, dependent: :destroy
  has_many :labels, dependent: :destroy
  has_many :notification_settings, dependent: :destroy
  has_many :hooks, dependent: :destroy, class_name: 'Integrations::Hook'
  has_many :working_hours, dependent: :destroy
  has_many :kbase_portals, dependent: :destroy, class_name: '::Kbase::Portal'
  has_many :kbase_categories, dependent: :destroy, class_name: '::Kbase::Category'
  has_many :kbase_articles, dependent: :destroy, class_name: '::Kbase::Article'
  has_many :teams, dependent: :destroy
  has_flags ACCOUNT_SETTINGS_FLAGS.merge(column: 'settings_flags').merge(DEFAULT_QUERY_SETTING)



  #   /////////////////////////   FFCRM  //////////////////

  serialize :subscribed_users, Set

  accepts_nested_attributes_for :billing_address,  allow_destroy: true, reject_if: proc { |attributes| Address.reject_address(attributes) }
  accepts_nested_attributes_for :shipping_address, allow_destroy: true, reject_if: proc { |attributes| Address.reject_address(attributes) }

  scope :state, lambda { |filters|
    where('category IN (?)' + (filters.delete('other') ? ' OR category IS NULL' : ''), filters)
  }
  scope :created_by,  ->(user) { where(user_id: user.id) }
  scope :assigned_to, ->(user) { where(assigned_to: user.id) }

  scope :text_search, ->(query) { ransack('name_or_email_cont' => query).result }

  scope :visible_on_dashboard, lambda { |user|
    # Show accounts which either belong to the user and are unassigned, or are assigned to the user
    where('(user_id = :user_id AND assigned_to IS NULL) OR assigned_to = :user_id', user_id: user.id)
  }

  scope :by_name, -> { order(:name) }

  # uses_user_permissions
  # acts_as_commentable
  # uses_comment_extensions
  # acts_as_taggable_on :tags
  # has_paper_trail versions: { class_name: 'Version' }, ignore: [:subscribed_users]
  # has_fields
  # exportable
  # sortable by: ["name ASC", "rating DESC", "created_at DESC", "updated_at DESC"], default: "created_at DESC"

  # has_ransackable_associations %w[contacts opportunities tags activities emails addresses comments tasks]
  # ransack_can_autocomplete

  validates_presence_of :name, message: :missing_account_name
  validates_uniqueness_of :name, scope: :deleted_at, if: -> { Setting.require_unique_account_names }
  validates :rating, inclusion: { in: 0..5 }, allow_blank: true
  validates :category, inclusion: { in: proc { Setting.unroll(:account_category).map { |s| s.last.to_s } } }, allow_blank: true
  validate :users_for_shared_access

  before_save :nullify_blank_category
  #    ///////////////////////////////////////////////////////////

  
  enum locale: LANGUAGES_CONFIG.map { |key, val| [val[:iso_639_1_code], key] }.to_h

  after_create_commit :notify_creation

  def agents
    users.where(account_users: { role: :agent })
  end

  def administrators
    users.where(account_users: { role: :administrator })
  end

  def all_conversation_tags
    # returns array of tags
    conversation_ids = conversations.pluck(:id)
    ActsAsTaggableOn::Tagging.includes(:tag)
                             .where(context: 'labels',
                                    taggable_type: 'Conversation',
                                    taggable_id: conversation_ids)
                             .map { |_| _.tag.name }
  end

  def webhook_data
    {
      id: id,
      name: name
    }
  end

  def inbound_email_domain
    domain || GlobalConfig.get('MAILER_INBOUND_EMAIL_DOMAIN')['MAILER_INBOUND_EMAIL_DOMAIN'] || ENV.fetch('MAILER_INBOUND_EMAIL_DOMAIN', false)
  end

  def support_email
    super || GlobalConfig.get('MAILER_SUPPORT_EMAIL')['MAILER_SUPPORT_EMAIL'] || ENV.fetch('MAILER_SENDER_EMAIL', 'Abrand <accounts@chatwoot.com>')
  end

  # //////////////////  FFCRM  ///////////
  def self.per_page
    20
  end

  # Extract last line of billing address and get rid of numeric zipcode.
  #----------------------------------------------------------------------------
  def location
    return "" unless self[:billing_address]

    location = self[:billing_address].strip.split("\n").last
    location&.gsub(/(^|\s+)\d+(:?\s+|$)/, " ")&.strip
  end

  # Attach given attachment to the account if it hasn't been attached already.
  #----------------------------------------------------------------------------
  def attach!(attachment)
    send(attachment.class.name.tableize) << attachment unless send("#{attachment.class.name.downcase}_ids").include?(attachment.id)
  end

  # Discard given attachment from the account.
  #----------------------------------------------------------------------------
  def discard!(attachment)
    if attachment.is_a?(Task)
      attachment.update_attribute(:asset, nil)
    else # Contacts, Opportunities
      send(attachment.class.name.tableize).delete(attachment)
    end
  end

  # Class methods.
  #----------------------------------------------------------------------------
  def self.create_or_select_for(model, params)
    # Attempt to find existing account
    return Account.find(params[:id]) if params[:id].present?

    if params[:name].present?
      account = Account.find_by(name: params[:name])
      return account if account
    end

    # Fallback to create new account
    params[:user] = model.user if model
    account = Account.new(params)
    if account.access != "Lead" || model.nil?
      account.save
    else
      account.save_with_model_permissions(model)
    end
    account
  end
  def users_for_shared_access
    errors.add(:access, :share_account) if self[:access] == "Shared" && permissions.none?
  end

  # ////////////////////////////////////////////////

  private

  def notify_creation
    Rails.configuration.dispatcher.dispatch(ACCOUNT_CREATED, Time.zone.now, account: self)
  end

  trigger.after(:insert).for_each(:row) do
    "execute format('create sequence IF NOT EXISTS conv_dpid_seq_%s', NEW.id);"
  end

  trigger.name('camp_dpid_before_insert').after(:insert).for_each(:row) do
    "execute format('create sequence IF NOT EXISTS camp_dpid_seq_%s', NEW.id);"
  end

  #  ////////////////////////////////////////  FFCRM  /////////////

  # Make sure at least one user has been selected if the account is being shared.
  #----------------------------------------------------------------------------


  def nullify_blank_category
    self.category = nil if category.blank?
  end

  # //////////////////////////////////////////// ////////////////////
end
