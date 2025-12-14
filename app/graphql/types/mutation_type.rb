# frozen_string_literal: true

module Types
  class MutationType < Types::BaseObject
    field :generate_access_token, mutation: Mutations::GenerateAccessToken
    field :purchase_gift_card, mutation: Mutations::PurchaseGiftCard
  end
end
