require 'double_entry'
require 'money'

DoubleEntry.configure do |config|
  Money.locale_backend = :currency
  Money.rounding_mode = BigDecimal::ROUND_HALF_UP

  Dollar = Money::Currency.find('USD')
  Money.default_currency = Dollar

  # Use json(b) column in double_entry_lines table to store metadata instead of separate metadata table
  config.json_metadata = true

  config.define_accounts do |accounts|
    user_scope = ->(user) do
      raise 'not a User' unless user.class.name == 'User'
      "user_#{user.id}"
    end

    accounts.define(identifier: AccountType::User::PRIMARY, scope_identifier: user_scope, positive_only: true)

    # ASK INTERNAL ACCOUNT OR USER ACCOUNT?
    accounts.define(identifier: AccountType::User::OUTGOING, scope_identifier: user_scope, positive_only: false)

    accounts.define(identifier: AccountType::Internal::GIFT_CARD_REVENUE, positive_only: true)
    accounts.define(identifier: AccountType::Internal::EXTERNAL_FUNDING, positive_only: false)
  end

  config.define_transfers do |transfers|
    transfers.define(from: AccountType::Internal::EXTERNAL_FUNDING, to: AccountType::User::PRIMARY,  code: TransactionCode::DEPOSIT)
    transfers.define(from: AccountType::User::PRIMARY,  to: AccountType::User::OUTGOING, code: TransactionCode::GIFT_CARD_PURCHASE)
    transfers.define(from: AccountType::User::OUTGOING  ,  to: AccountType::Internal::GIFT_CARD_REVENUE, code: TransactionCode::GIFT_CARD_FEE)
  end
end
