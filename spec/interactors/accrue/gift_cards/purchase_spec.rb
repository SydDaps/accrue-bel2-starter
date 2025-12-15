 # frozen_string_literal: true

require 'rails_helper'

RSpec.describe Accrue::GiftCards::Purchase, type: :interactor do
  describe '.call' do
    let(:user) { create(:user) }
    let(:gift_card) { create(:gift_card, price: 10000) }

    before do
      fund_user_account(user, 20000)
    end

    context 'successful purchase of a gift card' do
      it 'successfully purchases a gift card' do
        result = described_class.call(user_id: user.id, gift_card_id: gift_card.id)

        expect(result).to be_success
        expect(result.gift_card_order).to be_present
        expect(result.gift_card_order.user).to eq(user)
        expect(result.gift_card_order.gift_card).to eq(gift_card)
        expect(result.gift_card_order.status).to eq('completed')
        expect(result.gift_card_order.fee).to eq(100)
      end

      it 'creates a gift card order record' do
        expect {
          described_class.call(user_id: user.id, gift_card_id: gift_card.id)
        }.to change(GiftCardOrder, :count).by(1)
      end

      it 'transfers total amount from primary to outgoing account' do
        initial_primary_balance = user.balance.cents

        result = described_class.call(user_id: user.id, gift_card_id: gift_card.id)

        expect(result).to be_success

        user.reload
        final_primary_balance = user.balance.cents

        expect(final_primary_balance).to eq(initial_primary_balance - 10100)

        transfer_line = user.entry_lines(:outgoing, TransactionCode::GIFT_CARD_PURCHASE).first
        expect(transfer_line.amount.cents).to eq(10100)
      end

      it 'transfers fee from outgoing to revenue account' do
        initial_outgoing_balance = user.balance(Dollar, AccountType::User::OUTGOING).cents
        revenue_account = DoubleEntry::Account.account(AccountType::Internal::GIFT_CARD_REVENUE)
        initial_revenue_balance = revenue_account.balance.cents

        result = described_class.call(user_id: user.id, gift_card_id: gift_card.id)

        expect(result).to be_success

        user.reload
        final_outgoing_balance = user.balance(Dollar, AccountType::User::OUTGOING).cents
        revenue_account = DoubleEntry::Account.account(AccountType::Internal::GIFT_CARD_REVENUE)
        final_revenue_balance = revenue_account.balance.cents

        expect(final_outgoing_balance).to eq(initial_outgoing_balance + 10000)
        expect(final_revenue_balance).to eq(initial_revenue_balance + 100)
      end
    end

    context 'insufficient funds' do
      let(:expensive_gift_card) { create(:gift_card, price: 30000) }

      it 'fails with insufficient funds error' do
        result = described_class.call(user_id: user.id, gift_card_id: expensive_gift_card.id)

        expect(result).to be_failure
        expect(result.error[:type]).to eq(:insufficient_funds)
      end
    end

    # TODO: get clarity to proceed
    # context 'invalid purchase amount' do
    #   let(:free_gift_card) { create(:gift_card, price: 0) }

    #   it 'fails with invalid amount error' do
    #     result = described_class.call(user: user, gift_card_id: free_gift_card.id)

    #     expect(result).to be_failure
    #     expect(result.error).to include('must be greater than zero')
    #   end
    # end
  end
end
