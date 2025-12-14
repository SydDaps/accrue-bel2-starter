# frozen_string_literal: true

module Types
  class GiftCardOrderType < Types::BaseObject
    field :id, ID, null: false
    field :user, Types::UserType, null: false
    field :gift_card, Types::GiftCardType, null: false
    field :status, String, null: false
    field :fee, Integer, null: false, description: "Fee in cents"
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
  end
end
