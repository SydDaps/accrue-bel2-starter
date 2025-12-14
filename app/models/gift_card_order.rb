class GiftCardOrder < ApplicationRecord
  belongs_to :user
  belongs_to :gift_card

  enum :status, {
    pending: 'pending',
    completed: 'completed',
    failed: 'failed'
  }

  validates :status, presence: true, inclusion: { in: statuses.keys }
  validates :fee, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end
