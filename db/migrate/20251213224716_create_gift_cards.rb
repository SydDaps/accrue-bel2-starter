class CreateGiftCards < ActiveRecord::Migration[7.2]
  def change
    create_table :gift_cards do |t|
      t.string :slug
      t.string :name
      t.integer :price

      t.timestamps
    end
    add_index :gift_cards, :slug, unique: true
  end
end
