# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
# == Schema Information
#
# Table name: fields
#
#  id             :integer          not null, primary key
#  as             :string(32)
#  collection     :string
#  disabled       :boolean
#  hint           :string
#  klass_name     :string(32)
#  label          :string(128)
#  maxlength      :integer
#  minlength      :integer
#  name           :string(64)
#  placeholder    :string
#  position       :integer
#  required       :boolean
#  type           :string
#  created_at     :datetime
#  updated_at     :datetime
#  field_group_id :integer
#
# Indexes
#
#  index_fields_on_field_group_id  (field_group_id)
#  index_fields_on_klass_name      (klass_name)
#  index_fields_on_name            (name)
#

class CoreField < Field
  # Some CoreField attributes should be read-only
  attr_readonly :name, :as, :collection
  before_destroy :error_on_destroy

  def error_on_destroy
    errors.add_to_base "Core fields cannot be deleted."
  end

  ActiveSupport.run_load_hooks(:fat_free_crm_core_field, self)
end
