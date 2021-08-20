# frozen_string_literal: true

# == Schema Information
#
# Table name: lists
#
#  id         :integer          not null, primary key
#  name       :string
#  url        :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :integer
#
# Indexes
#
#  index_lists_on_user_id  (user_id)
#
class List < ActiveRecord::Base
  validates_presence_of :name
  validates_presence_of :url
  belongs_to :user

  # Parses the controller from the url
  def controller
    (url || "").sub(%r{\A/}, '').split(%r{/|\?}).first
  end

  ActiveSupport.run_load_hooks(:fat_free_crm_list, self)
end
