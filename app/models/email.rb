# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
# == Schema Information
#
# Table name: emails
#
#  id              :integer          not null, primary key
#  bcc             :string
#  body            :text
#  cc              :string
#  deleted_at      :datetime
#  header          :text
#  mediator_type   :string
#  received_at     :datetime
#  sent_at         :datetime
#  sent_from       :string           not null
#  sent_to         :string           not null
#  state           :string(16)       default("Expanded"), not null
#  subject         :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  imap_message_id :string           not null
#  mediator_id     :integer
#  user_id         :integer
#
# Indexes
#
#  index_emails_on_mediator_id_and_mediator_type  (mediator_id,mediator_type)
#

class Email < ActiveRecord::Base
  belongs_to :mediator, polymorphic: true, optional: true # TODO: Is this really optional?
  belongs_to :user, optional: true # TODO: Is this really optional?

  # has_paper_trail versions: { class_name: 'Version' }, meta: { related: :mediator },
  #                 ignore: [:state]

  def expanded?
    state == "Expanded"
  end

  def collapsed?
    state == "Collapsed"
  end

  def body_html
    body.to_s.gsub("\n", "<br>")
  end

  def body_inline
    body.to_s.tr("\n", " ")
  end

  ActiveSupport.run_load_hooks(:fat_free_crm_email, self)
end
