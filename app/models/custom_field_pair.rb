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
class CustomFieldPair < CustomField
  has_one :pair, class_name: 'CustomFieldPair', foreign_key: 'pair_id', dependent: :destroy # points to 'end'

  # Helper to create a pair. Used in fields_controller
  #------------------------------------------------------------------------------
  def self.create_pair(params)
    fields = params['field']
    as = params['field']['as']
    pair = params.delete('pair')
    base_params = fields.delete_if { |k, _v| !%w[field_group_id label as].include?(k) }
    klass = ("custom_field_" + as.gsub('pair', '_pair')).classify.constantize
    field1 = klass.create(base_params.merge(pair['0']))
    field2 = klass.create(base_params.merge(pair['1']).merge('pair_id' => field1.id, 'required' => field1.required, 'disabled' => field1.disabled))
    [field1, field2]
  end

  # Helper to update a pair. Used in fields_controller
  #------------------------------------------------------------------------------
  def self.update_pair(params)
    fields = params['field']
    pair = params.delete('pair')
    base_params = fields.delete_if { |k, _v| !%w[field_group_id label as].include?(k) }
    field1 = CustomFieldPair.find(params['id'])
    field1.update(base_params.merge(pair['0']))
    field2 = field1.paired_with
    field2.update(base_params.merge(pair['1']).merge('required' => field1.required, 'disabled' => field1.disabled))
    [field1, field2]
  end

  # Returns the field that this field is paired with
  #------------------------------------------------------------------------------
  def paired_with
    pair || CustomFieldPair.where(pair_id: id).first
  end

  ActiveSupport.run_load_hooks(:fat_free_crm_custom_field_pair, self)
end
