# frozen_string_literal: true

module Avatarable
  extend ActiveSupport::Concern
  include Rails.application.routes.url_helpers

  included do
    has_one_attached :avatar
  end

  def avatar_url
    # return url_for(avatar.representation(resize: '250x250')) if avatar? && avatar.representable?

    if [User, Contact].include?(self.class) && email.present?
      hash = Digest::MD5.hexdigest(email)
      return "https://www.gravatar.com/avatar/#{hash}"
    end
    ''
  end
end
