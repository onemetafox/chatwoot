# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
# == Schema Information
#
# Table name: permissions
#
#  id         :integer          not null, primary key
#  asset_type :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  asset_id   :integer
#  group_id   :integer
#  user_id    :integer
#
# Indexes
#
#  index_permissions_on_asset_id_and_asset_type  (asset_id,asset_type)
#  index_permissions_on_group_id                 (group_id)
#  index_permissions_on_user_id                  (user_id)
#

class Permission < ActiveRecord::Base
  belongs_to :user, optional: true
  belongs_to :group, optional: true
  belongs_to :asset, polymorphic: true, optional: true

  validates_presence_of :user_id, unless: :group_id?
  validates_presence_of :group_id, unless: :user_id?

  validates_uniqueness_of :user_id, scope: %i[group_id asset_id asset_type]

end
