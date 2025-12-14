require 'rails_helper'

RSpec.describe GiftCardOrder, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:status) }
    it { should validate_presence_of(:fee) }
    it { should validate_numericality_of(:fee).only_integer.is_greater_than_or_equal_to(0) }
  end

  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:gift_card) }
  end
end
