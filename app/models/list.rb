# frozen_string_literal: true

# == Schema Information
#
# Table name: lists
#
#  id         :bigint           not null, primary key
#  name       :string
#  url        :text
#  created_at :datetime
#  updated_at :datetime
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
