# loading installation configs
GlobalConfig.clear_cache
ConfigLoader.new.process
Logo.create_default

## Seeds productions
if Rails.env.production?
  # Setup Onboarding flow
  ::Redis::Alfred.set(::Redis::Alfred::CHATWOOT_INSTALLATION_ONBOARDING, true)
end

## Seeds for Local Development
#unless Rails.env.production?
  SuperAdmin.create!(email: 'admin2@admin.com', password: '1Qazxsw@3edc')

  account = Account.create!(
    name: 'Social'
  )

  secondary_account = Account.create!(
    name: 'Social'
  )

  user = User.new(username: "Admin", name: 'Administrator', email: 'admin2@admin.com', password: '1Qazxsw@3edc')
  user.skip_confirmation!
  user.save!
  AccountUser.create!(
    account_id: account.id,
    user_id: user.id,
    role: :administrator
  )

  AccountUser.create!(
    account_id: secondary_account.id,
    user_id: user.id,
    role: :administrator
  )

  # Enables creating additional accounts from dashboard
  installation_config = InstallationConfig.find_by(name: 'CREATE_NEW_ACCOUNT_FROM_DASHBOARD')
  installation_config.value = true
  installation_config.save!
  GlobalConfig.clear_cache

  web_widget = Channel::WebWidget.create!(account: account, website_url: 'https://acme.inc')

  inbox = Inbox.create!(channel: web_widget, account: account, name: 'Acme Support')
  InboxMember.create!(user: user, inbox: inbox)

  contact = Contact.create!(name: 'jane', email: 'jane3@example.com', phone_number: '+22320000', account: account, user: user)
  contact_inbox = ContactInbox.create!(inbox: inbox, contact: contact, source_id: user.id, hmac_verified: true)
  conversation = Conversation.create!(
    account: account,
    inbox: inbox,
    status: :open,
    assignee: user,
    contact: contact,
    contact_inbox: contact_inbox,
    additional_attributes: {}
  )

  # # sample email collect
  # WootMessageSeeder.create_sample_email_collect_message conversation

  # Message.create!(content: 'Hello every one', account: account, inbox: inbox, conversation: conversation, message_type: :incoming)

  # # sample card
  # WootMessageSeeder.create_sample_cards_message conversation
  # # input select
  # WootMessageSeeder.create_sample_input_select_message conversation
  # # form
  # WootMessageSeeder.create_sample_form_message conversation
  # # articles
  # WootMessageSeeder.create_sample_articles_message conversation

  # CannedResponse.create!(account: account, short_code: 'start', content: 'Hello welcome to chatwoot.')
#end
