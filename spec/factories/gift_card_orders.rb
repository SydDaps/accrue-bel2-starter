FactoryBot.define do
  factory :gift_card_order do
    user { nil }
    gift_card { nil }
    status { "MyString" }
    fee { 1 }
  end
end
