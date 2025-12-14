# frozen_string_literal: true

module Queries
  class GiftCards < Resolvers::BaseResolver
    type [Types::GiftCardType], null: false

    def resolve
      GiftCard.all
    end
  end
end
