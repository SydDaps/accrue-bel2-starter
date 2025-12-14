# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::PurchaseGiftCard, type: :request do
  let(:user) { create(:user) }
  let(:gift_card) { create(:gift_card, price: 2500) }
  let(:context) { { current_user: user } }

  let(:mutation) do
    <<~GQL
      mutation($giftCardId: ID!, $userId: ID!) {
        purchaseGiftCard(input: {
          giftCardId: $giftCardId
          userId: $userId
        }) {
          giftCardOrder {
            id
            status
            fee
            user {
              id
              username
            }
            giftCard {
              id
              name
              price
            }
          }
          errors {
            type
            message
          }
        }
      }
    GQL
  end

  def execute_mutation(context)
    variables = {
      giftCardId: gift_card.id.to_s,
      userId: user.id.to_s
    }
    execute_graphql(mutation, variables: variables, context: context)
  end

  describe 'authenticated user' do
    before do
      fund_user_account(user, 10000)
    end

    it 'successfully purchases a gift card' do
      result = execute_mutation(context)
      data = graphql_response(result)['purchaseGiftCard']

      expect(data['errors']).to be_nil
      expect(data['giftCardOrder']).to be_present
      expect(data['giftCardOrder']['status']).to eq('completed')
      expect(data['giftCardOrder']['fee']).to eq(25)
      expect(data['giftCardOrder']['user']['id']).to eq(user.id.to_s)
      expect(data['giftCardOrder']['giftCard']['id']).to eq(gift_card.id.to_s)
    end

    it 'creates a gift card order with correct attributes' do
      expect {
        execute_mutation(context)
      }.to change(GiftCardOrder, :count).by(1)

      result = execute_mutation(context)
      order_data = result['data']['purchaseGiftCard']['giftCardOrder']

      expect(order_data['status']).to eq('completed')
      expect(order_data['fee']).to eq(25)
      expect(order_data['giftCard']['id']).to eq(gift_card.id.to_s)
      expect(order_data['user']['id']).to eq(user.id.to_s)
    end

    context 'when user has insufficient funds' do
      let(:expensive_gift_card) { create(:gift_card, price: 30000) }

      it 'returns an insufficient funds error' do
        variables = {
          giftCardId: expensive_gift_card.id.to_s,
          userId: user.id.to_s
        }

        result = execute_graphql(mutation, variables: variables, context: context)
        data = graphql_response(result)['purchaseGiftCard']

        expect(data['giftCardOrder']).to be_nil
        expect(data['errors']).to be_present
        expect(data['errors'].first['type']).to eq('insufficient_funds')
        expect(data['errors'].first['message']).to eq('User has insufficient funds to complete the gift card purchase.')
      end
    end
  end

  describe 'unauthenticated user' do
    let(:context) { { current_user: nil } }

    it 'rejects the request' do
      variables = {
        giftCardId: gift_card.id.to_s,
        userId: user.id.to_s
      }

      result = execute_graphql(mutation, variables: variables, context: context)
      data = graphql_response(result)['purchaseGiftCard']

      expect(data['giftCardOrder']).to be_nil
      expect(data['errors']).to be_present
      expect(data['errors'].first['type']).to eq('unauthorized')
      expect(data['errors'].first['message']).to eq('Unauthorized')
    end
  end
end
