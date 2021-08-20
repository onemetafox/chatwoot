# == Schema Information
#
# Table name: versions
#
#  id             :integer          not null, primary key
#  event          :string(512)      not null
#  item_type      :string           not null
#  object         :text
#  object_changes :text
#  related_type   :string
#  whodunnit      :string
#  created_at     :datetime
#  item_id        :integer          not null
#  related_id     :integer
#
# Indexes
#
#  index_versions_on_created_at             (created_at)
#  index_versions_on_item_type_and_item_id  (item_type,item_id)
#  index_versions_on_whodunnit              (whodunnit)
#
class Version < ApplicationRecord
end
