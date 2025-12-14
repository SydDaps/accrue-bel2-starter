class User < ApplicationRecord
  include HasAccount

  has_secure_password

  has_many :gift_card_orders, dependent: :destroy

  validates :username, presence: true, uniqueness: true

  def balance(currency = Dollar, account_type = AccountType::User::PRIMARY)
    account(account_type, currency).balance.cents
  end
end
