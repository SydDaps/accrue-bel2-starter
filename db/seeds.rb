# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).

require 'json'

puts "Loading gift cards..."

gift_cards_file = Rails.root.join('db', 'data', 'gift_cards.json')
gift_cards_data = JSON.parse(File.read(gift_cards_file))

gift_cards_data.each do |card_data|
  GiftCard.find_or_create_by(slug: card_data['slug']) do |card|
    card.name = card_data['name']
    card.price = card_data['price']
  end
  puts "  Loaded: #{card_data['name']}"
end

puts "Done loading gift cards!"
