# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
# == Schema Information
#
# Table name: contact_opportunities
#
#  id             :integer          not null, primary key
#  deleted_at     :datetime
#  role           :string(32)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  contact_id     :integer
#  opportunity_id :integer
#
# Indexes
#
#  index_contact_opportunities_on_contact_id_and_opportunity_id  (contact_id,opportunity_id)
#

class ContactOpportunity < ActiveRecord::Base
  belongs_to :contact
  belongs_to :opportunity
  validates_presence_of :contact_id, :opportunity_id

  # has_paper_trail :class_name => 'Version'

  ActiveSupport.run_load_hooks(:fat_free_crm_contact_opportunity, self)
end
