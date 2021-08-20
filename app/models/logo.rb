# == Schema Information
#
# Table name: logos
#
#  id         :bigint           not null, primary key
#  title      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Logo < ApplicationRecord
  has_one_attached :avatar

  def self.default
    Logo.last || Logo.create_default
  end

  def self.create_default
    if Logo.count == 0
      logo = Logo.create(title: 'ABrand')
      logo.avatar.attach(io: File.open('public/brand-assets/logo.png'), filename: 'logo.png')
      logo
    end
  end
end
