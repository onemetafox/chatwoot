class DashboardController < ActionController::Base
  include SwitchLocale

  before_action :set_logo
  before_action :set_global_config
  around_action :switch_locale
  before_action :ensure_installation_onboarding, only: [:index]

  layout 'vueapp'

  def index; end

  private

  def set_global_config
    @global_config = GlobalConfig.get(
      'WIDGET_BRAND_URL',
      'TERMS_URL',
      'PRIVACY_URL',
      'DISPLAY_MANIFEST',
      'CREATE_NEW_ACCOUNT_FROM_DASHBOARD',
      'CHATWOOT_INBOX_TOKEN',
      'API_CHANNEL_NAME',
      'API_CHANNEL_THUMBNAIL',
      'API_CHANNEL_NAME',
      'API_CHANNEL_THUMBNAIL'
    ).merge(
      APP_VERSION: Chatwoot.config[:version],
      INSTALLATION_NAME: @logo.title,
      installationName: @logo.title,
      LOGO: url_for(@logo.avatar),
      LOGO_THUMBNAIL: url_for(@logo.avatar)
    )
  end

  def ensure_installation_onboarding
    puts 'nothing to do as of now'
    puts 'commenting as client does not want redirections'
    #redirect_to '/installation/onboarding' if ::Redis::Alfred.get(::Redis::Alfred::CHATWOOT_INSTALLATION_ONBOARDING)
  end

  private

  def set_logo
    @logo ||= Logo.default
  end
end
