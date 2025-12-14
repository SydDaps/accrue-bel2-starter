# frozen_string_literal: true

module Mutations
  class PurchaseGiftCard < BaseMutation
    argument :gift_card_id, ID, required: true
    argument :user_id, ID, required: true

    field :gift_card_order, Types::GiftCardOrderType, null: true

    def execute(gift_card_id:, user_id:)
      ensure_authorized!
      fetch_gift_card(gift_card_id)
      fetch_user(user_id)

      # TODO: ASK should Gift card be sent rather because we need it to create it
      result = Accrue::GiftCards::Purchase.call({user: @user, gift_card: @gift_card})

      if result.failure?
        raise_graphql_error(result.error[:type], result.error[:message])
      end


      {gift_card_order: result.gift_card_order}
    end

    def fetch_user(user_id)
      @user = User.find(user_id)
    end

    def fetch_gift_card(gift_card_id)
      @gift_card = GiftCard.find(gift_card_id)
    end
  end
end
