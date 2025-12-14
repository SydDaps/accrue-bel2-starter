# frozen_string_literal: true

module Types
  class QueryType < Types::BaseObject
    field :gift_cards, resolver: Queries::GiftCards, description: "Returns a list of available gift cards for purchase"
  end
end
