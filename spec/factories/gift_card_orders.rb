FactoryBot.define do
  factory :gift_card_order do
    user
    gift_card { GiftCard.first }
    status { :completed }
    fee { 100 }
  end
end
