require 'rails_helper'

RSpec.describe Moonboard, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:account) }
    it { is_expected.to have_many(:moonboard_items) }
  end
end
