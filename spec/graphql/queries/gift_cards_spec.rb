# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Queries::GiftCards, type: :request do
  describe '.resolve' do
    let!(:gift_card_1) { create(:gift_card, slug: 'amazon', name: 'Amazon', price: 5000) }
    let!(:gift_card_2) { create(:gift_card, slug: 'apple', name: 'Apple', price: 10000) }
    let!(:gift_card_3) { create(:gift_card, slug: 'google', name: 'Google', price: 7500) }

    let(:query) do
      <<~GQL
        query {
          giftCards {
            id
            slug
            name
            price
          }
        }
      GQL
    end

    it 'returns a list of gift cards' do
      result = execute_graphql(query)
      gift_cards = graphql_response(result)['giftCards']

      expect(gift_cards).to be_an(Array)
      expect(gift_cards.length).to eq(3)
    end

    it 'returns the correct fields for each gift card' do
      result = execute_graphql(query)
      gift_cards = graphql_response(result)['giftCards']

      first_gift_card = gift_cards.first

      expect(first_gift_card).to have_key('id')
      expect(first_gift_card).to have_key('slug')
      expect(first_gift_card).to have_key('name')
      expect(first_gift_card).to have_key('price')

      # Verify specific values for the first gift card
      expect(first_gift_card['slug']).to eq('amazon')
      expect(first_gift_card['name']).to eq('Amazon')
      expect(first_gift_card['price']).to eq(5000)
    end
  end
end
