FactoryBot.define do
  factory :gift_card do
    sequence(:slug) { |n| "gift-card-#{n}" }
    sequence(:name) { |n| "Gift Card #{n}" }
    price { 10000 } # $100.00 in cents
  end
end
