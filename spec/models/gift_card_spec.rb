require 'rails_helper'

RSpec.describe GiftCard, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:slug) }
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:price) }
    it { should validate_uniqueness_of(:slug) }
    it { should validate_numericality_of(:price).only_integer.is_greater_than(0) }
  end

  describe 'associations' do
    it { should have_many(:gift_card_orders).dependent(:destroy) }
  end
end
