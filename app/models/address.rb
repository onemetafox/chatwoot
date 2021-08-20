# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
# == Schema Information
#
# Table name: addresses
#
#  id               :integer          not null, primary key
#  address_type     :string(16)
#  addressable_type :string
#  city             :string(64)
#  country          :string(64)
#  deleted_at       :datetime
#  full_address     :string
#  state            :string(64)
#  street1          :string
#  street2          :string
#  zipcode          :string(16)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  addressable_id   :integer
#
# Indexes
#
#  index_addresses_on_addressable_id_and_addressable_type  (addressable_id,addressable_type)
#

class Address < ActiveRecord::Base
  belongs_to :addressable, polymorphic: true

  # has_paper_trail versions: { class_name: 'Version' }, meta: { related: :addressable }

  scope :business, -> { where("address_type='Business'") }
  scope :billing,  -> { where("address_type='Billing'") }
  scope :shipping, -> { where("address_type='Shipping'") }

  # Checks if the address is blank for both single and compound addresses.
  #----------------------------------------------------------------------------
  def blank?
    if Setting.compound_address
      %w[street1 street2 city state zipcode country].all? { |attr| send(attr).blank? }
    else
      full_address.blank?
    end
  end

  #----------------------------------------------------------------------------
  # Ensure blank address records don't get created. If we have a new record and
  #   address is empty then return true otherwise return false so that _destroy
  #   is processed (if applicable) and the record is removed.
  # Intended to be called as follows:
  #   accepts_nested_attributes_for :business_address, :allow_destroy => true, :reject_if => proc {|attributes| Address.reject_address(attributes)}
  def self.reject_address(attributes)
    exists = attributes['id'].present?
    empty = %w[street1 street2 city state zipcode country full_address].map { |name| attributes[name].blank? }.all?
    attributes[:_destroy] = 1 if exists && empty
    (!exists && empty)
  end
end
