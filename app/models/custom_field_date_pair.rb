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
class CustomFieldDatePair < CustomFieldPair
  # For rendering paired values
  # Handle case where both pairs are blank
  #------------------------------------------------------------------------------
  def render_value(object)
    return "" unless paired_with.present?

    from = render(object.send(name))
    to = render(object.send(paired_with.name))
    if from.present? && to.present?
      I18n.t('pair.from_to', from: from, to: to)
    elsif from.present? && !to.present?
      I18n.t('pair.from_only', from: from)
    elsif !from.present? && to.present?
      I18n.t('pair.to_only', to: to)
    else
      ""
    end
  end

  def render(value)
    value&.strftime(I18n.t("date.formats.mmddyy"))
  end

  def custom_validator(obj)
    super
    # validate when we get to 2nd of the pair
    if pair_id.present?
      start = CustomFieldPair.find(pair_id)
      return if start.nil?

      from = obj.send(start.name)
      to = obj.send(name)
      obj.errors.add(name.to_sym, ::I18n.t('activerecord.errors.models.custom_field.endbeforestart', field: start.label)) if from.present? && to.present? && (from > to)
    end
  end

  ActiveSupport.run_load_hooks(:fat_free_crm_date_pair, self)
end
