# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
# == Schema Information
#
# Table name: account_contacts
#
#  id         :integer          not null, primary key
#  deleted_at :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  account_id :integer
#  contact_id :integer
#

class AccountContact < ApplicationRecord
  belongs_to :account, counter_cache: :contacts_count
  belongs_to :contact

  # has_paper_trail versions: { class_name: 'Version' }, meta: { related: :contact },
  #                 ignore: %i[id created_at updated_at contact_id]

  validates_presence_of :account_id
end
