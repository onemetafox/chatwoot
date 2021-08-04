# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  admin                  :boolean          default(FALSE), not null
#  aim                    :string(32)
#  alt_email              :string(254)
#  authentication_token   :string
#  availability           :integer          default("online")
#  company                :string(64)
#  confirmation_sent_at   :datetime
#  confirmation_token     :string(255)
#  confirmed_at           :datetime
#  current_sign_in_at     :datetime
#  current_sign_in_ip     :string
#  deleted_at             :datetime
#  display_name           :string
#  email                  :string(254)      default(""), not null
#  encrypted_password     :string           default(""), not null
#  first_name             :string(32)
#  google                 :string(32)
#  last_name              :string(32)
#  last_sign_in_at        :datetime
#  last_sign_in_ip        :string
#  mobile                 :string(32)
#  name                   :string           not null
#  password_salt          :string           default(""), not null
#  phone                  :string(32)
#  provider               :string           default("email"), not null
#  pubsub_token           :string
#  remember_created_at    :datetime
#  remember_token         :string
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  sign_in_count          :integer          default(0), not null
#  skype                  :string(32)
#  suspended_at           :datetime
#  title                  :string(64)
#  tokens                 :json
#  ui_settings            :jsonb
#  uid                    :string           default(""), not null
#  unconfirmed_email      :string(254)
#  username               :string(32)       default(""), not null
#  yahoo                  :string(32)
#  created_at             :datetime
#  updated_at             :datetime
#
# Indexes
#
#  index_users_on_authentication_token     (authentication_token) UNIQUE
#  index_users_on_confirmation_token       (confirmation_token) UNIQUE
#  index_users_on_email                    (email)
#  index_users_on_pubsub_token             (pubsub_token) UNIQUE
#  index_users_on_remember_token           (remember_token) UNIQUE
#  index_users_on_reset_password_token     (reset_password_token) UNIQUE
#  index_users_on_uid_and_provider         (uid,provider) UNIQUE
#  index_users_on_username_and_deleted_at  (username,deleted_at) UNIQUE
#

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  include AccessTokenable
  include AvailabilityStatusable
  include Avatarable
  # Include default devise modules.
  include DeviseTokenAuth::Concerns::User
  include Pubsubable
  include Rails.application.routes.url_helpers
  include Reportable
  include SsoAuthenticatable

  devise :database_authenticatable,
         :registerable,
         :recoverable,
         :rememberable,
         :trackable,
         :validatable,
         :confirmable,
         :password_has_required_content

  enum availability: { online: 0, offline: 1, busy: 2 }

  #  //////////// F-Mode  ////////////
  before_create :suspend_if_needs_approval
  #  //////////// F-Mode  ////////////

  # The validation below has been commented out as it does not
  # work because :validatable in devise overrides this.
  # validates_uniqueness_of :email, scope: :account_id

  validates :email, :name, presence: true
  # validates_length_of :name, minimum: 1

  has_many :account_users, dependent: :destroy
  has_many :accounts, through: :account_users
  accepts_nested_attributes_for :account_users

  has_many :assigned_conversations, foreign_key: 'assignee_id', class_name: 'Conversation', dependent: :nullify
  alias_attribute :conversations, :assigned_conversations
  has_many :csat_survey_responses, foreign_key: 'assigned_agent_id', dependent: :nullify

  has_many :inbox_members, dependent: :destroy
  has_many :inboxes, through: :inbox_members, source: :inbox
  has_many :messages, as: :sender
  has_many :invitees, through: :account_users, class_name: 'User', foreign_key: 'inviter_id', dependent: :nullify

  has_many :notifications, dependent: :destroy
  has_many :notification_settings, dependent: :destroy
  has_many :notification_subscriptions, dependent: :destroy
  has_many :team_members, dependent: :destroy
  has_many :teams, through: :team_members
  has_many :moonboards, dependent: :destroy
  has_many :notes, dependent: :nullify
  has_many :custom_filters, dependent: :destroy
  #   ////////////////  Fat Free CRM Mode////////////
  

  has_one :avatar, as: :entity, dependent: :destroy  # Personal avatar.
  has_many :avatars                                  # As owner who uploaded it, ex. Contact avatar.
  has_many :comments, as: :commentable               # As owner who created a comment.
  has_many :accounts
  has_many :campaigns
  has_many :leads
  has_many :contacts
  has_many :opportunities
  has_many :assigned_opportunities, class_name: 'Opportunity', foreign_key: 'assigned_to'
  has_many :permissions, dependent: :destroy
  has_many :preferences, dependent: :destroy
  has_many :lists
  has_and_belongs_to_many :groups

  # //////////////////  F-Mode  /////////////////////////

  # has_paper_trail versions: { class_name: 'Version' }, ignore: [:last_sign_in_at]
  #   ////////////////  Fat Free CRM Mode////////////
  before_validation :set_password_and_uid, on: :create

  after_create_commit :create_access_token
  after_save :update_presence_in_redis, if: :saved_change_to_availability?
  scope :order_by_full_name, -> { order('lower(name) ASC') }

  # ///////////////////   F-Mode  ////////////
  scope :by_id, -> { order('id DESC') }
  # TODO: /home/clockwerx/.rbenv/versions/2.5.3/lib/ruby/gems/2.5.0/gems/activerecord-5.2.3/lib/active_record/scoping/named.rb:175:in `scope': You tried to define a scope named "without" on the model "User", but ActiveRecord::Relation already defined an instance method with the same name. (ArgumentError)
  scope :without_user, ->(user) { where('id != ?', user.id).by_name }
  scope :by_name, -> { order('first_name, last_name, email') }

  scope :text_search, lambda { |query|
    query = query.gsub(/[^\w\s\-\.'\p{L}]/u, '').strip
    where('upper(username) LIKE upper(:s) OR upper(email) LIKE upper(:s) OR upper(first_name) LIKE upper(:s) OR upper(last_name) LIKE upper(:s)', s: "%#{query}%")
  }

  scope :my, ->(current_user) { accessible_by(current_user.ability) }

  scope :have_assigned_opportunities, lambda {
    joins("INNER JOIN opportunities ON users.id = opportunities.assigned_to")
      .where("opportunities.stage <> 'lost' AND opportunities.stage <> 'won'")
      .select('DISTINCT(users.id), users.*')
  }

  # //////////////////  F-Mode  //////////////////


  def send_devise_notification(notification, *args)
    devise_mailer.with(account: Current.account).send(notification, self, *args).deliver_later
  end

  def set_password_and_uid
    self.uid = email
  end

  def active_account_user
    account_users.order(active_at: :desc)&.first
  end

  def current_account_user
    account_users.find_by(account_id: Current.account.id) if Current.account
  end

  def available_name
    self[:display_name].presence || name
  end

  def hmac_identifier
    hmac_key = GlobalConfig.get('CHATWOOT_INBOX_HMAC_KEY')['CHATWOOT_INBOX_HMAC_KEY']
    return OpenSSL::HMAC.hexdigest('sha256', hmac_key, email) if hmac_key.present?

    ''
  end

  def account
    current_account_user&.account
  end

  def assigned_inboxes
    administrator? ? Current.account.inboxes : inboxes.where(account_id: Current.account.id)
  end

  def administrator?
    current_account_user&.administrator?
  end

  def agent?
    current_account_user&.agent?
  end

  def role
    current_account_user&.role
  end

  def inviter
    current_account_user&.inviter
  end

  def serializable_hash(options = nil)
    super(options).merge(confirmed: confirmed?)
  end

  def push_event_data
    {
      id: id,
      name: name,
      available_name: available_name,
      avatar_url: avatar_url,
      type: 'user',
      availability_status: availability_status
    }
  end

  def webhook_data
    {
      id: id,
      name: name,
      email: email,
      type: 'user'
    }
  end

  # //////////////////  F-Mode  /////////////////////

  def name
    first_name.blank? ? username : first_name
  end

  #----------------------------------------------------------------------------
  def full_name
    first_name.blank? && last_name.blank? ? email : "#{first_name} #{last_name}".strip
  end

  #----------------------------------------------------------------------------
  def suspended?
    suspended_at != nil
  end

  #----------------------------------------------------------------------------
  def awaits_approval?
    suspended? && sign_in_count == 0 && Setting.user_signup == :needs_approval
  end

  def active_for_authentication?
    super && confirmed? && !awaits_approval? && !suspended?
  end

  def inactive_message
    if !confirmed?
      super
    elsif awaits_approval?
      I18n.t(:msg_account_not_approved)
    elsif suspended?
      I18n.t(:msg_invalig_login)
    else
      super
    end
  end

  #----------------------------------------------------------------------------
  def preference
    @preference ||= preferences.build
  end
  alias pref preference

  # Override global I18n.locale if the user has individual local preference.
  #----------------------------------------------------------------------------
  def set_individual_locale
    I18n.locale = preference[:locale] if preference[:locale]
  end

  # Generate the value of single access token if it hasn't been set already.
  #----------------------------------------------------------------------------
  # def to_json(_options = nil)
  #   [name].to_json
  # end

  def to_xml(_options = nil)
    [name].to_xml
  end

  def password_required?
    !persisted? || !password.nil? || !password_confirmation.nil?
  end

  # Returns permissions ability object.
  #----------------------------------------------------------------------------
  def ability
    @ability ||= Ability.new(self)
  end

  # Returns true if this user is allowed to be destroyed.
  #----------------------------------------------------------------------------
  def destroyable?(current_user)
    current_user != self && !has_related_assets?
  end

  # Suspend newly created user if signup requires an approval.
  #----------------------------------------------------------------------------
  def suspend_if_needs_approval
    self.suspended_at = Time.now if Setting.user_signup == :needs_approval && !admin
  end

  # Prevent deleting a user unless she has no artifacts left.
  #----------------------------------------------------------------------------
  def has_related_assets?
    sum = %w[Account Campaign Lead Contact Opportunity Comment Task].detect do |asset|
      klass = asset.constantize

      asset != "Comment" && klass.assigned_to(self).exists? || klass.created_by(self).exists?
    end
    !sum.nil?
  end

  # Define class methods
  #----------------------------------------------------------------------------
  class << self
    def can_signup?
      %i[allowed needs_approval].include? Setting.user_signup
    end

    # Overrides Devise sign-in to use either username or email (case-insensitive)
    #----------------------------------------------------------------------------
    def find_for_database_authentication(warden_conditions)
      conditions = warden_conditions.dup
      if login = conditions.delete(:email)
        where(conditions.to_h).where(["lower(username) = :value OR lower(email) = :value", { value: login.downcase }]).first
      end
    end
  end
  
  private

  def update_presence_in_redis
    accounts.each do |account|
      OnlineStatusTracker.set_status(account.id, id, availability)
    end
  end
end
