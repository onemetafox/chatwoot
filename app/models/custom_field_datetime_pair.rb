# frozen_string_literal: true

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
class CustomFieldDatetimePair < CustomFieldDatePair
  def render(value)
    value&.strftime(I18n.t("time.formats.mmddhhss"))
  end

  ActiveSupport.run_load_hooks(:fat_free_crm_datetime_pair, self)
end
