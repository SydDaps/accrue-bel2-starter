# frozen_string_literal: true

module Accrue
  module GiftCards
    class Purchase < ApplicationInteractor
      delegate :user_id, :gift_card_id, :user, :gift_card, :gift_card_order, :user_primary_account, :user_outgoing_account, :gift_card_revenue_account, :fee, :total_amount, to: :context

      def call
        context.user = find_user(user_id)
        context.gift_card = find_gift_card(gift_card_id)

        validate_amount
        calculate_total_amount
        fetch_accounts
        check_sufficient_funds

        with_locked_accounts([user_primary_account, user_outgoing_account, gift_card_revenue_account]) do
          debit_user_primary_account
          credit_gift_card_revenue_account
          create_order
        end
      end

      private

      def validate_amount
        gift_card = context.gift_card
        user = context.user

        fail!(ErrorTypes::INVALID_AMOUNT, "Gift card price must be greater than zero.") if gift_card.price <= 0
      end

      def calculate_total_amount
        gift_card = context.gift_card

        fee = (gift_card.price * 0.01).to_i
        total_amount = gift_card.price + fee

        context.fee = fee
        context.total_amount = total_amount
      end

      def check_sufficient_funds
        balance = user_primary_account.balance.cents

        if balance < total_amount
          fail!(ErrorTypes::INSUFFICIENT_FUNDS, "User has insufficient funds to complete the gift card purchase.")
        end
      end

      def fetch_accounts
        context.user_primary_account ||= user.account(AccountType::User::PRIMARY)
        context.user_outgoing_account ||= user.account(AccountType::User::OUTGOING)
        context.gift_card_revenue_account ||= DoubleEntry::Account.account(AccountType::Internal::GIFT_CARD_REVENUE)
      end

      def debit_user_primary_account
        DoubleEntry.transfer(
          Money.new(total_amount, Dollar),
          from: user_primary_account,
          to: user_outgoing_account,
          code: TransactionCode::GIFT_CARD_PURCHASE
        )
      end

      def credit_gift_card_revenue_account
        DoubleEntry.transfer(
          Money.new(fee, Dollar),
          from: user_outgoing_account,
          to: gift_card_revenue_account,
          code: TransactionCode::GIFT_CARD_FEE
        )
      end

      def create_order
        context.gift_card_order = GiftCardOrder.create!(
          user: user,
          gift_card: gift_card,
          fee: fee,
          status: :completed
        )
      end
    end
  end
end
