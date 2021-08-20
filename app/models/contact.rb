# == Schema Information
#
# Table name: contacts
#
#  id                    :integer          not null, primary key
#  access                :string(8)        default("Public")
#  additional_attributes :jsonb
#  alt_email             :string(254)
#  assigned_to           :integer
#  background_info       :string
#  blog                  :string(128)
#  born_on               :date
#  custom_attributes     :jsonb
#  deleted_at            :datetime
#  department            :string(64)
#  do_not_call           :boolean          default(FALSE), not null
#  email                 :string(254)
#  facebook              :string(128)
#  fax                   :string(32)
#  first_name            :string(64)       default(""), not null
#  identifier            :string
#  last_activity_at      :datetime
#  last_name             :string(64)       default(""), not null
#  linkedin              :string(128)
#  mobile                :string(32)
#  name                  :string
#  phone                 :string(32)
#  phone_number          :string
#  pubsub_token          :string
#  reports_to            :integer
#  skype                 :string(128)
#  source                :string(32)
#  subscribed_users      :text
#  title                 :string(64)
#  twitter               :string(128)
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  account_id            :integer          not null
#  lead_id               :integer
#  user_id               :integer
#
# Indexes
#
#  id_last_name_deleted                 (user_id,last_name,deleted_at) UNIQUE
#  index_contacts_on_account_id         (account_id)
#  index_contacts_on_assigned_to        (assigned_to)
#  index_contacts_on_pubsub_token       (pubsub_token) UNIQUE
#  uniq_email_per_account_contact       (email,account_id) UNIQUE
#  uniq_identifier_per_account_contact  (identifier,account_id) UNIQUE
#

class Contact < ApplicationRecord
  include Pubsubable
  include Avatarable
  include AvailabilityStatusable
  include Labelable

  validates :account_id, presence: true
  validates :email, allow_blank: true, uniqueness: { scope: [:account_id], case_sensitive: false }
  validates :identifier, allow_blank: true, uniqueness: { scope: [:account_id] }
  validates :phone_number,
            allow_blank: true, uniqueness: { scope: [:account_id] },
            format: { with: /\+[1-9]\d{1,14}\z/, message: 'should be in e164 format' }

  belongs_to :account
  has_many :conversations, dependent: :destroy
  has_many :contact_inboxes, dependent: :destroy
  has_many :inboxes, through: :contact_inboxes
  has_many :messages, as: :sender, dependent: :destroy

  before_validation :prepare_email_attribute
  after_create_commit :dispatch_create_event, :ip_lookup
  after_update_commit :dispatch_update_event

  # ///////////////////////   FFCRM  /////////////////////
  belongs_to :user
  belongs_to :lead, optional: true # TODO: Is this really optional?
  belongs_to :assignee, class_name: "User", foreign_key: :assigned_to, optional: true # TODO: Is this really optional?
  belongs_to :reporting_user, class_name: "User", foreign_key: :reports_to, optional: true # TODO: Is this really optional?
  has_one :account_contact, dependent: :destroy
  # has_one :account, through: :account_contact
  has_many :contact_opportunities, dependent: :destroy
  has_many :opportunities, -> { order("opportunities.id DESC").distinct }, through: :contact_opportunities
  has_many :tasks, as: :asset, dependent: :destroy # , :order => 'created_at DESC'
  has_one :business_address, -> { where(address_type: "Business") }, dependent: :destroy, as: :addressable, class_name: "Address"
  has_many :addresses, dependent: :destroy, as: :addressable, class_name: "Address" # advanced search uses this
  has_many :emails, as: :mediator

  delegate :campaign, to: :lead, allow_nil: true

  # has_ransackable_associations %w[account opportunities tags activities emails addresses comments tasks]
  # ransack_can_autocomplete

  serialize :subscribed_users, Set

  accepts_nested_attributes_for :business_address, allow_destroy: true, reject_if: proc { |attributes| Address.reject_address(attributes) }

  scope :created_by,  ->(user) { where(user_id: user.id) }
  scope :assigned_to, ->(user) { where(assigned_to: user.id) }

  scope :text_search, lambda { |query|
    t = Contact.arel_table
    # We can't always be sure that names are entered in the right order, so we must
    # split the query into all possible first/last name permutations.
    name_query = if query.include?(" ")
                   scope, *rest = query.name_permutations.map do |first, last|
                     t[:first_name].matches("%#{first}%").and(t[:last_name].matches("%#{last}%"))
                   end
                   rest.map { |r| scope = scope.or(r) } if scope
                   scope
                 else
                   t[:first_name].matches("%#{query}%").or(t[:last_name].matches("%#{query}%"))
    end

    other = t[:email].matches("%#{query}%").or(t[:alt_email].matches("%#{query}%"))
    other = other.or(t[:phone].matches("%#{query}%")).or(t[:mobile].matches("%#{query}%"))

    where(name_query.nil? ? other : name_query.or(other))
  }

  # uses_user_permissions
  # acts_as_commentable
  # uses_comment_extensions
  # acts_as_taggable_on :tags
  # has_paper_trail versions: { class_name: 'Version' }, ignore: [:subscribed_users]
  # has_fields
  # exportable
  # sortable by: ["first_name ASC", "last_name ASC", "created_at DESC", "updated_at DESC"], default: "created_at DESC"

  validates_presence_of :first_name, message: :missing_first_name, if: -> { Setting.require_first_names }
  validates_presence_of :last_name,  message: :missing_last_name,  if: -> { Setting.require_last_names  }
  # validate :users_for_shared_access

  validates_length_of :first_name, maximum: 64
  validates_length_of :last_name, maximum: 64
  validates_length_of :title, maximum: 64
  validates_length_of :department, maximum: 64
  validates_length_of :email, maximum: 254
  validates_length_of :alt_email, maximum: 254
  validates_length_of :phone, maximum: 32
  validates_length_of :mobile, maximum: 32
  validates_length_of :fax, maximum: 32
  validates_length_of :blog, maximum: 128
  validates_length_of :linkedin, maximum: 128
  validates_length_of :facebook, maximum: 128
  validates_length_of :twitter, maximum: 128
  validates_length_of :skype, maximum: 128
  # //////////////////////////////////////////////////////////

  def get_source_id(inbox_id)
    contact_inboxes.find_by!(inbox_id: inbox_id).source_id
  end

  def push_event_data
    {
      additional_attributes: additional_attributes,
      email: email,
      id: id,
      identifier: identifier,
      name: name,
      phone_number: phone_number,
      pubsub_token: pubsub_token,
      thumbnail: avatar_url,
      type: 'contact'
    }
  end

  def webhook_data
    {
      id: id,
      name: name,
      avatar: avatar_url,
      type: 'contact'
    }
  end

  def ip_lookup
    return unless account.feature_enabled?('ip_lookup')

    ContactIpLookupJob.perform_later(self)
  end

  def prepare_email_attribute
    # So that the db unique constraint won't throw error when email is ''
    self.email = nil if email.blank?
    email.downcase! if email.present?
  end

  def dispatch_create_event
    Rails.configuration.dispatcher.dispatch(CONTACT_CREATED, Time.zone.now, contact: self)
  end

  def dispatch_update_event
    Rails.configuration.dispatcher.dispatch(CONTACT_UPDATED, Time.zone.now, contact: self)
  end

  # /////////////////////////  FFCRM  /////////////////////
  def self.per_page
    20
  end

  def self.first_name_position
    "before"
  end

  #----------------------------------------------------------------------------
  def full_name(format = nil)
    if format.nil? || format == "before"
      "#{first_name} #{last_name}"
    else
      "#{last_name}, #{first_name}"
    end
  end
  alias name full_name

  # Backend handler for [Create New Contact] form (see contact/create).
  #----------------------------------------------------------------------------
  def save_with_account_and_permissions(params)
    save_account(params)
    result = save
    opportunities << Opportunity.find(params[:opportunity]) unless params[:opportunity].blank?
    result
  end

  # Backend handler for [Update Contact] form (see contact/update).
  #----------------------------------------------------------------------------
  def update_with_account_and_permissions(params)
    save_account(params)
    # Must set access before user_ids, because user_ids= method depends on access value.
    self.access = params[:contact][:access] if params[:contact][:access]
    self.attributes = params[:contact]
    save
  end

  # Attach given attachment to the contact if it hasn't been attached already.
  #----------------------------------------------------------------------------
  def attach!(attachment)
    send(attachment.class.name.tableize) << attachment unless send("#{attachment.class.name.downcase}_ids").include?(attachment.id)
  end

  # Discard given attachment from the contact.
  #----------------------------------------------------------------------------
  def discard!(attachment)
    if attachment.is_a?(Task)
      attachment.update_attribute(:asset, nil)
    else # Opportunities
      send(attachment.class.name.tableize).delete(attachment)
    end
  end

  # Class methods.
  #----------------------------------------------------------------------------
  def self.create_for(model, account, opportunity, params)
    attributes = {
      lead_id:     model.id,
      user_id:     params[:account][:user_id] || account.user_id,
      assigned_to: params[:account][:assigned_to],
      access:      params[:access]
    }
    %w[first_name last_name title source email alt_email phone mobile blog linkedin facebook twitter skype do_not_call background_info].each do |name|
      attributes[name] = model.send(name.intern)
    end

    contact = Contact.new(attributes)

    # Set custom fields.
    if model.class.respond_to?(:fields)
      model.class.fields.each do |field|
        contact.send "#{field.name}=", model.send(field.name) if contact.respond_to?(field.name)
      end
    end

    contact.business_address = Address.new(street1: model.business_address.street1, street2: model.business_address.street2, city: model.business_address.city, state: model.business_address.state, zipcode: model.business_address.zipcode, country: model.business_address.country, full_address: model.business_address.full_address, address_type: "Business") unless model.business_address.nil?

    # Save the contact only if the account and the opportunity have no errors.
    if account.errors.empty? && opportunity.errors.empty?
      # Note: contact.account = account doesn't seem to work here.
      contact.account_contact = AccountContact.new(account: account, contact: contact) unless account.id.blank?
      if contact.access != "Lead" || model.nil?
        contact.save
      else
        contact.save_with_model_permissions(model)
      end
      contact.opportunities << opportunity unless opportunity.id.blank? # must happen after contact is saved
    end
    contact
  end
  def users_for_shared_access
    errors.add(:access, :share_contact) if self[:access] == "Shared" && permissions.none?
  end
  private

  # Make sure at least one user has been selected if the contact is being shared.
  #----------------------------------------------------------------------------
  

  # Handles the saving of related accounts
  #----------------------------------------------------------------------------
  def save_account(params)
    account_params = params[:account]
    valid_account = account_params && (account_params[:id].present? || account_params[:name].present?)
    self.account = if valid_account
                     Account.create_or_select_for(self, account_params)
                   else
                     nil
                   end
  end
  # ////////////////////////////////////////////////////////
end
