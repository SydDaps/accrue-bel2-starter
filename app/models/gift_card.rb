class GiftCard < ApplicationRecord
  has_many :gift_card_orders, dependent: :destroy

  validates :slug, presence: true, uniqueness: true
  validates :name, presence: true
  validates :price, presence: true, numericality: { only_integer: true, greater_than: 0 }
end
