# frozen_string_literal: true

module Mutations
  class PurchaseGiftCard < BaseMutation
    argument :gift_card_id, ID, required: true
    argument :user_id, ID, required: true

    field :gift_card_order, Types::GiftCardOrderType, null: true

    def execute(gift_card_id:, user_id:)
      ensure_authorized!

      result = Accrue::GiftCards::Purchase.call!(user_id: user_id, gift_card_id: gift_card_id)

      {gift_card_order: result.gift_card_order}
    end
  end
end
