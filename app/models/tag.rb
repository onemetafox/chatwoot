# frozen_string_literal: true

# == Schema Information
#
# Table name: tags
#
#  id             :integer          not null, primary key
#  name           :string
#  taggings_count :integer          default(0)
#
# Indexes
#
#  index_tags_on_name  (name) UNIQUE
#
class Tag < ActsAsTaggableOn::Tag
  before_destroy :no_associated_field_groups

  # Don't allow a tag to be deleted if it is associated with a Field Group
  def no_associated_field_groups
    FieldGroup.where(tag_id: id).none?
  end

  # Returns a count of taggings per model klass
  # e.g. {"Contact" => 3, "Account" => 1}
  def model_tagging_counts
    Tagging.where(tag_id: id).group(:taggable_type).count
  end

end
